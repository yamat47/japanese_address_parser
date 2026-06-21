# frozen_string_literal: true

# Port of: https://github.com/geolonia/normalize-japanese-addresses/blob/49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e/src/lib/normalizeHelpers.ts
# Upstream: @geolonia/normalize-japanese-addresses v3.1.3

require 'japanese_address_parser/v4/zen2han'

module JapaneseAddressParser
  module V4
    # 入力住所に対する前正規化（prenormalize）。NFC 化・スペース正規化・全角英数の半角化・
    # 数字に隣接する各種横棒のハイフン統一・丁目/区郡/番地以前のスペース削除を行う。
    module NormalizeHelpers
      # 数字の前後で統一する横棒（ハイフン・マイナス・長音記号・罫線等）の文字クラス。
      DASH = /[-－﹣−‐⁃‑‒–—﹘―⎯⏤ーｰ─━]/.freeze
      # JS: /([0-9０-９一二三四五六七八九〇十百千][横棒])|([横棒])[0-9０-９一二三四五六七八九〇十]/g
      # 先頭側の数字クラスは「百千」を含むが、横棒の後ろ側は「十」までで非対称（上流のまま）。
      NUMBER_ADJACENT_DASH = /([0-9０-９一二三四五六七八九〇十百千]#{DASH.source})|(#{DASH.source})[0-9０-９一二三四五六七八九〇十]/.freeze
      # JS: /(.+)(丁目?|番(町|地|丁)|条|軒|線|(の|ノ)町|地割)/（g フラグ無し）
      BEFORE_CHOME = /(.+)(丁目?|番(町|地|丁)|条|軒|線|(の|ノ)町|地割)/.freeze
      # JS: /(.+)((郡.+(町|村))|((市|巿).+(区|區)))/（g フラグ無し）
      BEFORE_KU_GUN = /(.+)((郡.+(町|村))|((市|巿).+(区|區)))/.freeze
      # JS: /.+?[0-9一二三四五六七八九〇十百千]-/（g フラグ無し）
      BEFORE_FIRST_NUMBER_DASH = /.+?[0-9一二三四五六七八九〇十百千]-/.freeze

      private_constant :DASH
      private_constant :NUMBER_ADJACENT_DASH
      private_constant :BEFORE_CHOME
      private_constant :BEFORE_KU_GUN
      private_constant :BEFORE_FIRST_NUMBER_DASH

      module_function

      # JS: prenormalize(input)
      # /g 有無を厳守する（前半 4 つは g=gsub、後半 3 つは g 無し=sub）。
      def prenormalize(input)
        input
          .unicode_normalize(:nfc)
          .gsub(/　/, ' ')
          .gsub(/ +/, ' ')
          .gsub(/([０-９Ａ-Ｚａ-ｚ]+)/) { |match| Zen2han.call(match) }
          .gsub(NUMBER_ADJACENT_DASH) { |match| match.gsub(DASH, '-') }
          .sub(BEFORE_CHOME) { |match| match.gsub(/ /, '') }
          .sub(BEFORE_KU_GUN) { |match| match.gsub(/ /, '') }
          .sub(BEFORE_FIRST_NUMBER_DASH) { |match| match.gsub(/ /, '') }
      end
    end
    public_constant :NormalizeHelpers
  end
end
