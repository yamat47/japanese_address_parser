# frozen_string_literal: true

# Port of: https://github.com/geolonia/normalize-japanese-addresses/blob/49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e/src/lib/zen2han.ts
# Upstream: @geolonia/normalize-japanese-addresses v3.1.3

module JapaneseAddressParser
  # 全角の英数字（Ａ-Ｚ・ａ-ｚ・０-９）を半角へ変換する。
  module Zen2han
    module_function

    # JS:
    #   str.replace(/[Ａ-Ｚａ-ｚ０-９]/g, (s) => String.fromCharCode(s.charCodeAt(0) - 0xfee0))
    # 全角英数字のコードポイントは半角より 0xFEE0 大きいので、その差を引いて半角へ落とす。
    # 文字クラスは上流のリテラル範囲をそのまま移植する。
    def call(str)
      str.gsub(/[Ａ-Ｚａ-ｚ０-９]/) { |s| (s.ord - 0xFEE0).chr(::Encoding::UTF_8) }
    end
  end
  public_constant :Zen2han
end
