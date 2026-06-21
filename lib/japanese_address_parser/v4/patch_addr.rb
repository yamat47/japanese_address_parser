# frozen_string_literal: true

# Port of: https://github.com/geolonia/normalize-japanese-addresses/blob/49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e/src/lib/patchAddr.ts
# Upstream: @geolonia/normalize-japanese-addresses v3.1.3

module JapaneseAddressParser
  module V4
    # 特定の町について番地表記のゆれを補正する 3 パッチを適用する。
    module PatchAddr
      # JS の addrPatches。pattern は上流では '^字?家[6六]' のように `^` 始端アンカーを使う。
      # JS の `^`（m フラグ無し）は「文字列先頭」を指すが、Ruby の `^` は「行頭」を指すため、
      # 文字列先頭の意味を保つには `\A` へ翻訳する必要がある（working_agreement §3-4 の
      # JS↔Onigmo 差異。挙動の忠実性を優先し `^` → `\A` と訳す）。
      ADDR_PATCHES = [
        { pref: '香川県', city: '仲多度郡まんのう町', town: '勝浦', pattern: '\A字?家[6六]', result: '家六' },
        { pref: '愛知県', city: 'あま市', town: '西今宿', pattern: '\A字?梶村[1一]', result: '梶村一' },
        { pref: '香川県', city: '丸亀市', town: '原田町', pattern: '\A字?東三分[1一]', result: '東三分一' }
      ].freeze

      private_constant :ADDR_PATCHES

      module_function

      # JS: patchAddr(prefName, cityName, townName, addr)
      # JS は param を直接変更しないよう `let _addr = addr` を使うが、Ruby では仮引数
      # addr を再代入して同じ動作にする（_addr 接頭辞は Lint/UnderscorePrefixedVariableName）。
      def call(pref_name, city_name, town_name, addr)
        ADDR_PATCHES.each do |patch|
          next unless patch[:pref] == pref_name && patch[:city] == city_name && patch[:town] == town_name

          # JS: _addr.replace(new RegExp(patch.pattern), patch.result)
          # new RegExp は g フラグ無し（最初の 1 件のみ）なので sub。result は literal。
          addr = addr.sub(::Regexp.new(patch[:pattern]), patch[:result])
        end

        addr
      end
    end
    public_constant :PatchAddr
  end
end
