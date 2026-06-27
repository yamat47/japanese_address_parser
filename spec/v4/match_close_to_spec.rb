# frozen_string_literal: true

require 'japanese_address_parser/v4/address'
require 'japanese_address_parser/v4/normalize_result'
require 'japanese_address_parser/v4/normalize_result_point'
require 'japanese_address_parser/v4/data/single_city'
require_relative 'support/match_close_to'

# match_close_to マッチャ自体のユニットテスト（ネットワーク不要）。
# ライブ CDN を叩く移植スイート（main_spec 等）と、PR2 の addresses.csv 全件 diff が依存する基盤。
# 近似比較・部分一致・未知キーガードをここで決定的に固定する（point 近似比較パスは level 8 が
# pending の間、ここだけが実際に exercise する）。
::RSpec.describe(::MatchCloseToHelper) do
  def build_address(pref: nil, city: nil, town: nil, other: '', point: nil, level: 0)
    prefecture = pref && { code: 13, pref: pref, pref_k: 'X', pref_r: 'X', point: [139.0, 35.0] }
    single_city = city && ::JapaneseAddressParser::V4::Data::SingleCity.from_json('code' => 1, 'city' => city, 'city_k' => 'X', 'city_r' => 'X', 'point' => [139.0, 35.0])
    machi_aza = town && { machiaza_id: '1', oaza_cho: town, chome: nil, chome_n: nil, koaza: nil, point: nil }
    metadata = ::JapaneseAddressParser::V4::NormalizeResultMetadata.new(input: 'x', prefecture: prefecture, city: single_city, machi_aza: machi_aza, chiban: nil, rsdt: nil)
    result = ::JapaneseAddressParser::V4::NormalizeResult.new(pref: pref, city: city, town: town, addr: nil, other: other, point: point, level: level, metadata: metadata)
    ::JapaneseAddressParser::V4::Address.from_normalize_result(result)
  end

  def point(lat, lng, level)
    ::JapaneseAddressParser::V4::NormalizeResultPoint.new(lat: lat, lng: lng, level: level)
  end

  it 'matches when the specified scalar fields are equal (and ignores unspecified fields)' do
    address = build_address(pref: '東京都', city: '渋谷区', town: '道玄坂', other: 'x', level: 3)
    expect(address).to(match_close_to(pref: '東京都', level: 3))
  end

  it 'does not match when a specified scalar field differs' do
    address = build_address(pref: '東京都', level: 1)
    expect(address).not_to(match_close_to(pref: '大阪府', level: 1))
  end

  describe 'point comparison' do
    let(:address) { build_address(level: 3, point: point(35.0, 139.0, 3)) }

    # 既定 precision=2 → 許容差 0.5*10**-2 = 0.005（包含）。0.003 は通り、0.01 は外れる
    # （3 桁=0.0005 だったら 0.003 で外れるはずなので、既定が 2 であることを固定する）。
    it 'matches coordinates within the default (precision 2) tolerance' do
      expect(address).to(match_close_to(point: { lat: 35.003, lng: 139.003, level: 3 }))
    end

    it 'does not match coordinates outside the tolerance' do
      expect(address).not_to(match_close_to(point: { lat: 35.01, lng: 139.0, level: 3 }))
    end

    it 'does not match when the point level differs (strict on level)' do
      expect(address).not_to(match_close_to(point: { lat: 35.0, lng: 139.0, level: 8 }))
    end

    it 'does not match when a point is expected but absent' do
      expect(build_address(level: 0)).not_to(match_close_to(point: { lat: 35.0, lng: 139.0, level: 3 }))
    end
  end

  it 'raises on an unknown expected key rather than silently comparing nil' do
    address = build_address(pref: '東京都', level: 1)
    expect { expect(address).to(match_close_to(full_address: 'x')) }
      .to(raise_error(::ArgumentError, /unknown expected key/))
  end
end
