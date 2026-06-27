# frozen_string_literal: true

# Port of test/helpers.ts `assertMatchCloseTo`（`jest-matcher-deep-close-to` の `toMatchCloseTo`）。
# 上流テストは NormalizeResult を「部分一致（expected に在るキーのみ）＋数値は近似一致」で検証する。
# v4 公開 API は Address VO を返すため、期待値は上流 NormalizeResult のキー名
# （pref/city/town/addr/other/level/point）で渡し、Address のフィールドへマッピングして比較する。
#
# 近似許容差は jest-matcher-deep-close-to の cmpNumber を移植:
#   |a - b| <= calculatePrecision(p)、calculatePrecision(p) = 0.5 * 10**(-p)。比較は `<=`（包含）。
# decimals 既定は同ライブラリの既定（precision = 2）に合わせる。

module MatchCloseToHelper
  DEFAULT_DECIMALS = 2
  public_constant :DEFAULT_DECIMALS

  module_function

  # Address を上流 NormalizeResult のキー名（pref/city/town/...）へ写した Hash。
  def normalized_fields(address)
    {
      pref: address.prefecture&.name,
      city: address.city&.name,
      town: address.town&.name,
      addr: address.addr,
      other: address.other,
      level: address.level,
      point: address.point
    }
  end

  # jest-matcher-deep-close-to の cmpNumber を移植: |a - b| <= 0.5 * 10**(-decimals)。
  # 比較は `<=`（包含。上流 calculatePrecision と同値で、RSpec の be_within(δ).of と同じ境界）。
  def close?(actual, expected, decimals)
    return false unless actual.is_a?(::Numeric) && expected.is_a?(::Numeric)

    (actual - expected).abs <= (0.5 * (10**-decimals))
  end

  # 不一致キーの説明文配列を返す（空なら一致）。
  # PR2（addresses.csv 全件）・PR3 でも共有するため、未知の期待キーは黙って nil 比較せず明示的に落とす。
  def mismatches(address, expected, decimals)
    actual = normalized_fields(address)
    unknown = expected.keys - actual.keys
    raise(::ArgumentError, "unknown expected key(s): #{unknown.join(', ')}") unless unknown.empty?

    expected.filter_map do |key, exp|
      key == :point ? point_mismatch(actual[key], exp, decimals) : scalar_mismatch(key, actual[key], exp)
    end
  end

  def scalar_mismatch(key, actual, expected)
    return if actual == expected

    "#{key}: expected #{expected.inspect}, got #{actual.inspect}"
  end

  # point は lat/lng を近似比較、level は厳密比較する。
  def point_mismatch(actual, expected, decimals)
    return "point: expected #{expected.inspect}, got nil" if actual.nil?

    errors = []
    errors << "lat #{actual.lat} !~ #{expected[:lat]}" unless close?(actual.lat, expected[:lat], decimals)
    errors << "lng #{actual.lng} !~ #{expected[:lng]}" unless close?(actual.lng, expected[:lng], decimals)
    # 上流は level も close-to で見るが、level は整数のため厳密比較で等価（0.0005 未満 ⇔ 同値）。
    errors << "level #{actual.level} != #{expected[:level]}" unless actual.level == expected[:level]
    errors.empty? ? nil : "point: #{errors.join(', ')}"
  end
end

# 使い方: expect(::JapaneseAddressParser::V4.call(addr)).to(match_close_to(pref: '神奈川県', level: 1))
::RSpec::Matchers.define(:match_close_to) do |expected, decimals = ::MatchCloseToHelper::DEFAULT_DECIMALS|
  match do |address|
    ::MatchCloseToHelper.mismatches(address, expected, decimals).empty?
  end

  failure_message do |address|
    mismatches = ::MatchCloseToHelper.mismatches(address, expected, decimals)
    "expected the normalized address to match (numbers close to #{decimals} decimals), but:\n" +
      mismatches.map { |m| "  - #{m}" }
                .join("\n")
  end
end
