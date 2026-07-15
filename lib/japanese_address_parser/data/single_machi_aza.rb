# frozen_string_literal: true

# Port of: https://github.com/geolonia/japanese-addresses-v2/blob/bb4d000ae136d8b8b571ebccd39a772cc6afc67a/src/data.ts
# Upstream: @geolonia/japanese-addresses-v2 v0.0.5 (data spec for @geolonia/normalize-japanese-addresses v3.1.3)

module JapaneseAddressParser
  module Data
    # SingleMachiAza — api/ja/{都道府県名}/{市区町村名}.json の data 要素（町字）。
    # `rsdt` は値が存在するとき必ず `true`（住居表示住所データの存在フラグ）。
    # `csv_ranges` は level 8 で住居表示/地番 CSV の該当バイト範囲を引くために保持する。
    SingleMachiAza =
      ::Data.define(:machiaza_id, :oaza_cho, :oaza_cho_k, :oaza_cho_r, :chome, :chome_n, :koaza, :koaza_k, :koaza_r, :rsdt, :point, :csv_ranges) do
        # JS: machiAzaName(machiAza) => `${oaza_cho || ''}${chome || ''}${koaza || ''}`
        # nil の補間は Ruby では空文字になるため `|| ''` 相当。
        def machi_aza_name
          "#{oaza_cho}#{chome}#{koaza}"
        end

        # JSON（パース済み Hash・文字列キー）から VO を生成する Ruby 独自ヘルパ。
        # csv_ranges は `{ "住居表示" => { "start" => Integer, "length" => Integer }, "地番" => {...} }`
        # の構造をそのまま保持する（M8 で消費する）。
        def self.from_json(hash)
          new(
            machiaza_id: hash['machiaza_id'],
            oaza_cho: hash['oaza_cho'],
            oaza_cho_k: hash['oaza_cho_k'],
            oaza_cho_r: hash['oaza_cho_r'],
            chome: hash['chome'],
            chome_n: hash['chome_n'],
            koaza: hash['koaza'],
            koaza_k: hash['koaza_k'],
            koaza_r: hash['koaza_r'],
            rsdt: hash['rsdt'],
            point: hash['point'],
            csv_ranges: hash['csv_ranges']
          )
        end
      end
    public_constant :SingleMachiAza
  end
end
