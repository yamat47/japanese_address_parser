# frozen_string_literal: true

module JapaneseAddressParser
  module Normalizers
    module Core
      module Inspired
        # 特定の住所パターンに対する修正処理
        #
        # @geolonia/normalize-japanese-addresses v2.10.0
        # src/lib/patchAddr.ts から移植
        # https://github.com/geolonia/normalize-japanese-addresses/blob/v2.10.0/src/lib/patchAddr.ts
        module PatchAddr
          # 住所修正パターン定義
          # https://github.com/geolonia/normalize-japanese-addresses/blob/v2.10.0/src/lib/patchAddr.ts#L1-L23
          ADDR_PATCHES = [
            {
              pref: '香川県',
              city: '仲多度郡まんのう町',
              town: '勝浦',
              pattern: /^字?家[6六]/,
              result: '家六'
            },
            {
              pref: '愛知県',
              city: 'あま市',
              town: '西今宿',
              pattern: /^字?梶村[1一]/,
              result: '梶村一'
            },
            {
              pref: '香川県',
              city: '丸亀市',
              town: '原田町',
              pattern: /^字?東三分[1一]/,
              result: '東三分一'
            }
          ].freeze

          # 住所文字列にパッチを適用
          #
          # @geolonia/normalize-japanese-addresses v2.10.0
          # src/lib/patchAddr.ts#L25-L40
          def self.patch_addr(pref, city, town, addr)
            result_addr = addr

            ADDR_PATCHES.each do |patch|
              result_addr = result_addr.gsub(patch[:pattern], patch[:result]) if patch[:pref] == pref && patch[:city] == city && patch[:town] == town
            end

            result_addr
          end
        end
      end
    end
  end
end
