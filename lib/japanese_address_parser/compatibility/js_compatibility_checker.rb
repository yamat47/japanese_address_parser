# frozen_string_literal: true

require_relative '../address_normalizer'
require 'json'
require 'csv'

module JapaneseAddressParser
  module Compatibility
    # JavaScript実装との互換性をチェックするツール
    #
    # Pure Ruby実装と@geolonia/normalize-japanese-addresses の
    # 結果を比較し、差異を検出・レポートする
    class JsCompatibilityChecker
      # サンプル住所のリスト
      TEST_ADDRESSES = [
        # 基本的なパターン
        '東京都千代田区千代田1-1',
        '東京都渋谷区恵比寿1-1-1',
        '大阪府大阪市北区梅田1-1-1',
        
        # 政令指定都市
        '北海道札幌市中央区北1条西2丁目',
        '神奈川県横浜市西区みなとみらい2-2-1',
        
        # 郡を含むパターン
        '埼玉県比企郡滑川町福田750-1',
        '千葉県印旛郡酒々井町中央台3-4-1',
        
        # 京都の通り名
        '京都府京都市中京区寺町通御池上る上本能寺前町488番地',
        '京都府京都市上京区今出川通烏丸東入相国寺門前町701',
        
        # 旧字体・異体字
        '東京都渋谷区澁谷1-1-1',
        '神奈川県横濱市中區本町1-1',
        
        # 表記ゆらぎ
        '茨城県つくば市天王台1-1-1',
        '茨城県ツクバ市天王台1-1-1',
        
        # 全角数字・漢数字
        '東京都港区芝１－２－３',
        '東京都港区芝一丁目二番三号',
        
        # 特殊なケース
        '沖縄県那覇市おもろまち4-1-1',
        '北海道札幌市中央区南3条西5丁目1-1'
      ].freeze

      def initialize
        @ruby_normalizer = ::JapaneseAddressParser::AddressNormalizer
        @results = []
      end

      # 互換性チェックを実行
      def check_compatibility(addresses = TEST_ADDRESSES)
        addresses.each do |address|
          check_single_address(address)
        end
        
        @results
      end

      # 単一の住所をチェック
      def check_single_address(address)
        ruby_result = normalize_with_ruby(address)
        js_result = normalize_with_javascript(address)
        
        differences = find_differences(ruby_result, js_result)
        
        @results << {
          address: address,
          ruby_result: ruby_result,
          js_result: js_result,
          differences: differences,
          compatible: differences.empty?
        }
      end

      # Ruby実装で正規化
      def normalize_with_ruby(address)
        @ruby_normalizer.call(address)
      rescue => e
        { 'error' => e.message }
      end

      # JavaScript実装で正規化
      def normalize_with_javascript(address)
        # JavaScript実装を呼び出す（現在はモック）
        # 実際には call_with_javascript メソッドを使用
        @ruby_normalizer.call_with_javascript(address)
      rescue => e
        { 'error' => e.message }
      end

      # 結果の差分を検出
      def find_differences(ruby_result, js_result)
        differences = {}
        
        %w[pref city town addr level lat lng].each do |key|
          ruby_value = ruby_result[key]
          js_value = js_result[key]
          
          # 緯度経度は小数点以下6桁で比較
          if %w[lat lng].include?(key) && ruby_value && js_value
            ruby_value = ruby_value.round(6) if ruby_value.is_a?(Float)
            js_value = js_value.round(6) if js_value.is_a?(Float)
          end
          
          if ruby_value != js_value
            differences[key] = {
              ruby: ruby_value,
              javascript: js_value
            }
          end
        end
        
        differences
      end

      # レポートを生成
      def generate_report
        total = @results.length
        compatible = @results.count { |r| r[:compatible] }
        incompatible = total - compatible
        
        report = []
        report << "=" * 60
        report << "JavaScript互換性チェックレポート"
        report << "=" * 60
        report << "総テスト数: #{total}"
        report << "互換: #{compatible} (#{(compatible * 100.0 / total).round(2)}%)"
        report << "非互換: #{incompatible}"
        report << ""
        
        if incompatible > 0
          report << "差異が検出された住所:"
          report << "-" * 40
          
          @results.reject { |r| r[:compatible] }.each do |result|
            report << ""
            report << "住所: #{result[:address]}"
            
            result[:differences].each do |key, diff|
              report << "  #{key}:"
              report << "    Ruby: #{diff[:ruby].inspect}"
              report << "    JS:   #{diff[:javascript].inspect}"
            end
          end
        end
        
        report.join("\n")
      end

      # CSVファイルに結果を出力
      def export_to_csv(filename)
        CSV.open(filename, 'w') do |csv|
          csv << ['住所', '互換性', '差異フィールド', 'Ruby結果', 'JS結果']
          
          @results.each do |result|
            if result[:compatible]
              csv << [result[:address], '○', '', '', '']
            else
              result[:differences].each do |key, diff|
                csv << [
                  result[:address],
                  '×',
                  key,
                  diff[:ruby],
                  diff[:javascript]
                ]
              end
            end
          end
        end
      end

      # 大量のテストデータでチェック
      def check_bulk_compatibility(csv_file)
        addresses = CSV.read(csv_file, headers: true).map { |row| row['address'] }
        check_compatibility(addresses)
      end

      # パフォーマンス比較
      def benchmark_performance(addresses = TEST_ADDRESSES)
        require 'benchmark'
        
        ruby_time = 0
        js_time = 0
        
        Benchmark.bm(20) do |x|
          ruby_time = x.report("Ruby実装:") do
            addresses.each { |addr| normalize_with_ruby(addr) }
          end
          
          js_time = x.report("JavaScript実装:") do
            addresses.each { |addr| normalize_with_javascript(addr) }
          end
        end
        
        {
          ruby_time: ruby_time.real,
          js_time: js_time.real,
          ratio: ruby_time.real / js_time.real
        }
      end
    end
  end
end