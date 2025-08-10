# frozen_string_literal: true

require_relative 'pipeline'

module JapaneseAddressParser
  module Normalizers
    # Pure Ruby実装の住所正規化モジュール
    #
    # JavaScriptに依存しない純粋なRuby実装
    # @geolonia/normalize-japanese-addresses の前処理部分を再現
    module PureRuby
      # 住所文字列を正規化する
      #
      # @param address [String, nil] 正規化対象の住所文字列
      # @return [String] 正規化された住所文字列
      def self.normalize(address)
        return '' if address.nil? || address.empty?

        # パイプラインを通じて正規化
        ::JapaneseAddressParser::Normalizers::Pipeline.normalize(address)
      end

      # 前処理として町丁目名より前のスペースを削除
      #
      # @param address [String] 住所文字列
      # @return [String] スペースが削除された住所文字列
      def self.remove_spaces_before_town(address)
        return '' if address.nil? || address.empty?

        # 基本正規化を先に実行
        normalized = normalize(address)

        # 町丁目、番地、条のパターンを探す
        # 最右の町レベル識別子を探し、その前のすべてのスペースを削除
        if normalized =~ /(.+?)(\s*[0-9０-９一二三四五六七八九〇十百千万]*(?:丁目|番地|条).*)/
          prefix = ::Regexp.last_match[1]
          suffix = ::Regexp.last_match[2]
          prefix.gsub(/ /, '') + suffix.gsub(/\A\s+/, '')
        else
          normalized
        end
      end

      # 前処理として市区郡より前のスペースを削除
      #
      # @param address [String] 住所文字列
      # @return [String] スペースが削除された住所文字列
      def self.remove_spaces_before_city(address)
        return '' if address.nil? || address.empty?

        # 基本正規化を先に実行
        normalized = normalize(address)

        # 市区町村郡のパターンを探す
        # 最右の市レベル識別子を探し、その前のすべてのスペースを削除
        if normalized =~ /(.+?)(\s*[市区町村郡].*)/
          prefix = ::Regexp.last_match[1]
          suffix = ::Regexp.last_match[2]
          prefix.gsub(/ /, '') + suffix.gsub(/\A\s+/, '')
        else
          normalized
        end
      end

      # 完全な正規化処理
      #
      # @param address [String, nil] 正規化対象の住所文字列
      # @return [String] 正規化された住所文字列
      def self.full_normalize(address)
        return '' if address.nil? || address.empty?

        # パイプラインによる基本正規化
        normalized = normalize(address)

        # 段階的なスペース処理
        # スペースを特殊な記号に置き換えて保護してから削除する

        # 保護対象のスペースを特殊記号に置き換え
        # 1. 方向 + 数字 + 識別子 (西 15丁目)
        normalized = normalized.gsub(/([東西南北]) +(\d+[丁目番地])/, '\1__SPACE__\2')

        # 2. 数字 + 番 (2番)
        normalized = normalized.gsub(/([市区町村郡丁目]) +(\d+番)/, '\1__SPACE__\2')

        # 3. 数字 + 条通 (3条通) - 区の後のもののみ
        normalized = normalized.gsub(/([市区町村郡]) +(\d+条通?)/, '\1__SPACE__\2')

        # 4. 条の後の方向 (3条 西)
        normalized = normalized.gsub(/(\d+条) +([東西南北])/, '\1__SPACE__\2')

        # 5. 英数字で始まる建物名 (A棟)
        normalized = normalized.gsub(/(丁目|番地|番|条) +([A-Za-z]\w*)/, '\1__SPACE__\2')

        # 全てのスペースを削除
        normalized = normalized.gsub(/ +/, '')

        # 保護されたスペースを復元
        normalized = normalized.gsub(/__SPACE__/, ' ')

        normalized.strip
      end
    end
  end
end
