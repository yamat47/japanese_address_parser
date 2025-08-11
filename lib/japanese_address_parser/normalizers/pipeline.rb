# frozen_string_literal: true

require_relative 'core/inspired/nfc_normalizer'
require_relative 'core/inspired/space_normalizer'
require_relative 'core/inspired/zen2han'
require_relative 'core/inspired/hyphen_normalizer'
require_relative 'core/inspired/text_variants'
require_relative 'core/inspired/kan2num'

module JapaneseAddressParser
  module Normalizers
    # 正規化処理のパイプライン
    #
    # @geolonia/normalize-japanese-addresses v2.10.0 の
    # 正規化処理の流れを再現
    module Pipeline
      # デフォルトの正規化器リスト（適用順序）
      DEFAULT_NORMALIZERS = [
        Core::Inspired::NfcNormalizer,
        Core::Inspired::SpaceNormalizer,
        Core::Inspired::Zen2han,
        Core::Inspired::HyphenNormalizer,
        Core::Inspired::TextVariants,
        Core::Inspired::Kan2num
      ].freeze

      @normalizers = DEFAULT_NORMALIZERS.dup

      class << self
        attr_reader :normalizers
      end

      # 文字列を正規化する
      #
      # @param str [String, nil] 正規化対象の文字列
      # @return [String] 正規化された文字列
      def self.normalize(str)
        return '' if str.nil?

        result = str
        @normalizers.each do |normalizer|
          result = normalizer.normalize(result)
        end
        result
      end

      # カスタム正規化器を追加
      #
      # @param normalizer [Module] normalizeメソッドを持つモジュール
      def self.add_normalizer(normalizer)
        @normalizers << normalizer
      end

      # 正規化器リストをリセット
      def self.reset_normalizers
        @normalizers = DEFAULT_NORMALIZERS.dup
      end
    end
  end
end
