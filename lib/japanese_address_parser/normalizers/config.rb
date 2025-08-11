# frozen_string_literal: true

module JapaneseAddressParser
  module Normalizers
    # 正規化処理の設定管理
    #
    # パイプラインのカスタマイズ、キャッシュ設定、
    # エンジン切り替えなどの設定を管理
    class Config
      attr_accessor :normalizer_engine, :pipeline_stages, :cache_size, :cache_enabled, :use_geolonia_data, :parallel_processing

      def initialize
        reset_to_defaults
      end

      def reset_to_defaults
        # 正規化エンジンの選択 (:ruby or :javascript)
        @normalizer_engine = :ruby

        # パイプラインステージの設定
        # 順番が重要: NFCで正規化 -> スペース削除 -> 全角半角 -> ハイフン統一 -> 表記ゆらぎ -> 漢数字
        @pipeline_stages = %i[nfc space zen2han hyphen text_variants kan2num]

        # キャッシュ設定
        @cache_enabled = true
        @cache_size = 1000

        # データソース設定
        @use_geolonia_data = true

        # パフォーマンス設定
        @parallel_processing = false
      end

      # パイプラインステージの有効/無効を切り替え
      #
      # @param stage [Symbol] ステージ名
      # @param enabled [Boolean] 有効/無効
      def set_stage(stage, enabled)
        if enabled && !@pipeline_stages.include?(stage)
          @pipeline_stages << stage
        elsif !enabled
          @pipeline_stages.delete(stage)
        end
      end

      # カスタムステージを追加
      #
      # @param stage [Symbol] ステージ名
      # @param position [Integer, nil] 挿入位置（nilの場合は末尾）
      def add_custom_stage(stage, position = nil)
        if position
          @pipeline_stages.insert(position, stage)
        else
          @pipeline_stages << stage
        end
      end

      # ステージの順序を変更
      #
      # @param stages [Array<Symbol>] 新しいステージ順序
      def reorder_stages(stages)
        @pipeline_stages = stages
      end

      # 設定を検証
      #
      # @return [Boolean] 設定が有効かどうか
      def valid?
        return false unless %i[ruby javascript].include?(@normalizer_engine)
        return false if @cache_size.negative?
        return false if @pipeline_stages.empty?

        true
      end

      # 設定をハッシュとして取得
      #
      # @return [Hash] 設定のハッシュ表現
      def to_h
        {
          normalizer_engine: @normalizer_engine,
          pipeline_stages: @pipeline_stages,
          cache_enabled: @cache_enabled,
          cache_size: @cache_size,
          use_geolonia_data: @use_geolonia_data,
          parallel_processing: @parallel_processing
        }
      end

      # ハッシュから設定をロード
      #
      # @param hash [Hash] 設定ハッシュ
      def load_from_hash(hash)
        @normalizer_engine = hash[:normalizer_engine] if hash.key?(:normalizer_engine)
        @pipeline_stages = hash[:pipeline_stages] if hash.key?(:pipeline_stages)
        @cache_enabled = hash[:cache_enabled] if hash.key?(:cache_enabled)
        @cache_size = hash[:cache_size] if hash.key?(:cache_size)
        @use_geolonia_data = hash[:use_geolonia_data] if hash.key?(:use_geolonia_data)
        @parallel_processing = hash[:parallel_processing] if hash.key?(:parallel_processing)
      end

      # 環境変数から設定をロード
      def load_from_env
        # JAPANESE_ADDRESS_PARSER_ENGINE
        @normalizer_engine = ENV['JAPANESE_ADDRESS_PARSER_ENGINE'].to_sym if ENV['JAPANESE_ADDRESS_PARSER_ENGINE']

        # JAPANESE_ADDRESS_PARSER_CACHE_SIZE
        @cache_size = ENV['JAPANESE_ADDRESS_PARSER_CACHE_SIZE'].to_i if ENV['JAPANESE_ADDRESS_PARSER_CACHE_SIZE']

        # JAPANESE_ADDRESS_PARSER_CACHE_ENABLED
        @cache_enabled = ENV['JAPANESE_ADDRESS_PARSER_CACHE_ENABLED'] != 'false' if ENV['JAPANESE_ADDRESS_PARSER_CACHE_ENABLED']

        # JAPANESE_ADDRESS_PARSER_PARALLEL
        @parallel_processing = ENV['JAPANESE_ADDRESS_PARSER_PARALLEL'] == 'true' if ENV['JAPANESE_ADDRESS_PARSER_PARALLEL']
      end
    end

    # グローバル設定インスタンス
    @config = Config.new

    class << self
      attr_reader :config
    end

    # 設定ブロックを使用して設定を変更
    #
    # @yield [Config] 設定オブジェクト
    def self.configure
      yield(@config) if block_given?
      @config
    end

    # 設定をリセット
    def self.reset_config
      @config = Config.new
    end

    # 現在の設定を取得
    def self.current_config
      @config.to_h
    end
  end
end
