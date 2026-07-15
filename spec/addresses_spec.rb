# frozen_string_literal: true

# Port of test/addresses/addresses.test.ts。addresses.csv の全行を JapaneseAddressParser.call で検証する全件 diff テスト。
# 上流同様ライブ CDN を叩く（working_agreement §1-8、:upstream_port）。上流はリトライ/キャッシュ無し
# （concurrency: 4 で直叩き）なので本移植も対策を入れず逐次でライブ CDN を叩く。
#
# level 0-3 も level 8（rsdt/chiban）も全行アクティブで、上流 normalize と同値になることを検証する。
# （RSpec/Pending はインライン disable 不可のため .rubocop.yml でこのファイルを除外している。）

require 'csv'
require 'japanese_address_parser'
require_relative 'support/match_close_to'

::RSpec.describe(::JapaneseAddressParser, :upstream_port) do
  # CSV 列: 住所, 都道府県, 市区町村, 町字, 番地号, その他, レベル, 緯度経度, 位置情報レベル, 備考
  # 緯度経度は "lng,lat" がクオートされているため素朴な split は不可。一方 Ruby の CSV.read は
  # 本ファイルのクオート併用行で MalformedCSVError を出す（上流 Papa.parse は寛容）。各物理行は単独で
  # 正当な CSV レコード（埋め込み改行なし）なので、行ごとに CSV.parse_line する。drop(1) でヘッダ除去。
  fixture_path = ::File.expand_path('fixtures/addresses.csv', __dir__.to_s)
  rows = ::File.readlines(fixture_path, chomp: true).reject(&:empty?).map { |line| ::CSV.parse_line(line) }
               .compact
  # 空欄（''）を nil 化するヘルパ。expected を compact したとき空欄キーを落とす（other は常に保持するので対象外）。
  presence = ->(value) { value.to_s.empty? ? nil : value }

  rows.drop(1).each do |row|
    address = row[0].to_s
    expected_level = Integer(row[6].to_s, 10)
    test_name = row[9].to_s.empty? ? address : "#{address} (#{row[9]})"

    point =
      if row[7].to_s.empty?
        nil
      else
        lng, lat = row[7].to_s.split(',').map { |value| Float(value) }
        { lng:, lat:, level: Integer(row[8].to_s, 10) }
      end

    # 上流 addresses.test.ts の match 構築を逐語移植:
    #   other/level は常に、pref/city/town/addr は非空なら、point は緯度経度があれば付与。
    # 空欄は nil にして compact で落とす（＝上流の「非空なら付与」と等価）。
    expected = { pref: presence.call(row[1]), city: presence.call(row[2]), town: presence.call(row[3]), addr: presence.call(row[4]), other: row[5].to_s, level: expected_level, point: }.compact

    it test_name do
      expect(described_class.call(address)).to(match_close_to(**expected))
    end
  end
end
