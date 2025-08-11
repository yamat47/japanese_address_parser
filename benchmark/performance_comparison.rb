#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'benchmark'
require 'japanese_address_parser'

# オプション: メモリベンチマーク用
begin
  require 'benchmark/memory'
rescue LoadError
  # benchmark-memory gem がない場合はスキップ
end

# パフォーマンスベンチマーク
#
# Pure Ruby実装と JavaScript実装のパフォーマンスを比較
class PerformanceComparison
  # テスト用住所リスト
  TEST_ADDRESSES = [
    '東京都千代田区千代田1-1',
    '東京都渋谷区恵比寿1-1-1',
    '大阪府大阪市北区梅田1-1-1',
    '北海道札幌市中央区北1条西2丁目',
    '神奈川県横浜市西区みなとみらい2-2-1',
    '埼玉県比企郡滑川町福田750-1',
    '千葉県印旛郡酒々井町中央台3-4-1',
    '京都府京都市中京区寺町通御池上る上本能寺前町488番地',
    '京都府京都市上京区今出川通烏丸東入相国寺門前町701',
    '東京都渋谷区澁谷1-1-1',
    '神奈川県横濱市中區本町1-1',
    '茨城県つくば市天王台1-1-1',
    '茨城県ツクバ市天王台1-1-1',
    '東京都港区芝１－２－３',
    '東京都港区芝一丁目二番三号',
    '沖縄県那覇市おもろまち4-1-1',
    '北海道札幌市中央区南3条西5丁目1-1',
    '愛知県名古屋市中区三の丸3-1-1',
    '福岡県福岡市博多区博多駅前2-1-1',
    '宮城県仙台市青葉区国分町3-7-1'
  ].freeze

  def initialize
    @normalizer = JapaneseAddressParser::AddressNormalizer
  end

  # 実行時間ベンチマーク
  def run_time_benchmark
    puts '=' * 60
    puts '実行時間ベンチマーク'
    puts '=' * 60
    puts

    # ウォームアップ
    puts 'ウォームアップ中...'
    warm_up

    # ベンチマーク実行
    results = {}
    iterations = 100

    Benchmark.bm(20) do |x|
      # Pure Ruby実装
      if ruby_available?
        results[:ruby] = x.report('Pure Ruby:') do
          iterations.times do
            TEST_ADDRESSES.each do |address|
              @normalizer.call(address)
            end
          end
        end
      end

      # JavaScript実装
      if javascript_available?
        results[:javascript] = x.report('JavaScript:') do
          iterations.times do
            TEST_ADDRESSES.each do |address|
              @normalizer.call_with_javascript(address)
            end
          end
        end
      end
    end

    # 比較結果
    if results[:ruby] && results[:javascript]
      puts
      puts '比較結果:'
      ruby_time = results[:ruby].real
      js_time = results[:javascript].real
      ratio = ruby_time / js_time

      if ratio < 1
        puts "  Pure Ruby実装の方が #{((1 - ratio) * 100).round(2)}% 高速"
      else
        puts "  JavaScript実装の方が #{((ratio - 1) * 100).round(2)}% 高速"
      end
    end

    puts
  end

  # メモリ使用量ベンチマーク
  def run_memory_benchmark
    puts '=' * 60
    puts 'メモリ使用量ベンチマーク'
    puts '=' * 60
    puts

    return unless defined?(Benchmark::Memory)

    Benchmark.memory do |x|
      # Pure Ruby実装
      if ruby_available?
        x.report('Pure Ruby:') do
          TEST_ADDRESSES.each do |address|
            @normalizer.call(address)
          end
        end
      end

      # JavaScript実装
      if javascript_available?
        x.report('JavaScript:') do
          TEST_ADDRESSES.each do |address|
            @normalizer.call_with_javascript(address)
          end
        end
      end

      x.compare!
    end

    puts
  end

  # 個別住所の処理時間測定
  def run_detailed_benchmark
    puts '=' * 60
    puts '個別住所の処理時間'
    puts '=' * 60
    puts

    results = []

    TEST_ADDRESSES.first(5).each do |address|
      ruby_time = nil
      js_time = nil

      # Pure Ruby実装
      if ruby_available?
        ruby_time = Benchmark.realtime do
          100.times { @normalizer.call(address) }
        end
      end

      # JavaScript実装
      if javascript_available?
        js_time = Benchmark.realtime do
          100.times { @normalizer.call_with_javascript(address) }
        end
      end

      results << {
        address: address,
        ruby: ruby_time,
        javascript: js_time
      }
    end

    # 結果表示
    puts '住所                                          | Ruby(ms) | JS(ms) | 比率'
    puts '-' * 75

    results.each do |result|
      address = result[:address].ljust(45)
      ruby_ms = result[:ruby] ? (result[:ruby] * 10).round(2) : 'N/A'
      js_ms = result[:javascript] ? (result[:javascript] * 10).round(2) : 'N/A'
      
      if result[:ruby] && result[:javascript]
        ratio = (result[:ruby] / result[:javascript]).round(2)
      else
        ratio = 'N/A'
      end

      puts "#{address} | #{ruby_ms.to_s.rjust(8)} | #{js_ms.to_s.rjust(6)} | #{ratio}"
    end

    puts
  end

  # スループット測定
  def run_throughput_benchmark
    puts '=' * 60
    puts 'スループット測定（処理数/秒）'
    puts '=' * 60
    puts

    duration = 5 # 秒

    # Pure Ruby実装
    if ruby_available?
      count = 0
      start_time = Time.now

      while Time.now - start_time < duration
        TEST_ADDRESSES.each do |address|
          @normalizer.call(address)
          count += 1
        end
      end

      ruby_throughput = count / duration
      puts "Pure Ruby:    #{ruby_throughput.round(0)} addresses/sec"
    end

    # JavaScript実装
    if javascript_available?
      count = 0
      start_time = Time.now

      while Time.now - start_time < duration
        TEST_ADDRESSES.each do |address|
          @normalizer.call_with_javascript(address)
          count += 1
        end
      end

      js_throughput = count / duration
      puts "JavaScript:   #{js_throughput.round(0)} addresses/sec"
    end

    puts
  end

  # 大量データ処理ベンチマーク
  def run_bulk_benchmark
    puts '=' * 60
    puts '大量データ処理ベンチマーク（1000件）'
    puts '=' * 60
    puts

    # テストデータを1000件に拡張
    bulk_addresses = TEST_ADDRESSES * 50 # 20 * 50 = 1000

    # Pure Ruby実装
    if ruby_available?
      ruby_time = Benchmark.realtime do
        bulk_addresses.each do |address|
          @normalizer.call(address)
        end
      end
      puts "Pure Ruby:    #{ruby_time.round(3)} 秒"
    end

    # JavaScript実装
    if javascript_available?
      js_time = Benchmark.realtime do
        bulk_addresses.each do |address|
          @normalizer.call_with_javascript(address)
        end
      end
      puts "JavaScript:   #{js_time.round(3)} 秒"
    end

    puts
  end

  private

  # ウォームアップ
  def warm_up
    3.times do
      TEST_ADDRESSES.first(3).each do |address|
        @normalizer.call(address) if ruby_available?
        @normalizer.call_with_javascript(address) if javascript_available?
      end
    end
  end

  # Pure Ruby実装が利用可能か
  def ruby_available?
    @normalizer.respond_to?(:call)
  rescue StandardError
    false
  end

  # JavaScript実装が利用可能か
  def javascript_available?
    @normalizer.respond_to?(:call_with_javascript)
  rescue StandardError
    false
  end
end

# メイン実行
if __FILE__ == $0
  benchmark = PerformanceComparison.new

  puts 'Japanese Address Parser パフォーマンスベンチマーク'
  puts '=' * 60
  puts "Ruby バージョン: #{RUBY_VERSION}"
  puts "プロセッサ: #{`sysctl -n machdep.cpu.brand_string 2>/dev/null`.strip}" if RUBY_PLATFORM =~ /darwin/
  puts "実行時刻: #{Time.now}"
  puts

  # 各ベンチマークを実行
  benchmark.run_time_benchmark
  benchmark.run_detailed_benchmark
  benchmark.run_throughput_benchmark
  benchmark.run_bulk_benchmark

  # メモリベンチマーク（gem が入っている場合のみ）
  begin
    require 'benchmark-memory'
    benchmark.run_memory_benchmark
  rescue LoadError
    puts 'メモリベンチマークをスキップ（benchmark-memory gem が必要）'
  end

  puts '=' * 60
  puts 'ベンチマーク完了'
  puts '=' * 60
end