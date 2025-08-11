#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'rspec/core'
require 'stringio'

# 各種テストを個別に実行して結果を集計
class TestRunner
  def run
    puts "=" * 80
    puts "既存テストスイートの実行結果"
    puts "=" * 80
    puts

    test_groups = [
      {
        name: "Models",
        path: "spec/japanese_address_parser/models/"
      },
      {
        name: "Address Normalizer",
        path: "spec/japanese_address_parser/address_normalizer/"
      },
      {
        name: "Normalizers (Core/Inspired)",
        path: "spec/japanese_address_parser/normalizers/core/inspired/"
      },
      {
        name: "Normalizers (Core/Extensions)",
        path: "spec/japanese_address_parser/normalizers/core/extensions/"
      },
      {
        name: "Normalizers (Pipeline)",
        path: "spec/japanese_address_parser/normalizers/pipeline_spec.rb"
      },
      {
        name: "Normalizers (Pure Ruby)",
        path: "spec/japanese_address_parser/normalizers/pure_ruby_spec.rb"
      }
    ]

    results = []
    
    test_groups.each do |group|
      puts "【#{group[:name]}】"
      puts "-" * 40
      
      # RSpec実行
      config = RSpec.configuration
      config.reset
      config.pattern = group[:path]
      
      # 出力をキャプチャ
      output = StringIO.new
      config.output_stream = output
      config.formatter = 'progress'
      
      runner = RSpec::Core::Runner.new(nil)
      exit_code = runner.run([group[:path]], output, output)
      
      # 結果を解析
      output_str = output.string
      if output_str =~ /(\d+) examples?, (\d+) failures?/
        examples = $1.to_i
        failures = $2.to_i
        
        status = failures == 0 ? "✅" : "❌"
        puts "#{status} 実行: #{examples}, 失敗: #{failures}"
        
        results << {
          name: group[:name],
          examples: examples,
          failures: failures
        }
      else
        puts "⚠️ テスト結果を解析できませんでした"
      end
      
      # 失敗の詳細があれば表示
      if output_str =~ /Failed examples:/
        puts "失敗したテスト:"
        output_str.scan(/rspec (.+) # (.+)/).each do |file, desc|
          puts "  - #{desc}"
        end
      end
      
      puts
    end
    
    # サマリー
    puts "=" * 80
    puts "【サマリー】"
    puts "=" * 80
    
    total_examples = results.sum { |r| r[:examples] }
    total_failures = results.sum { |r| r[:failures] }
    
    puts "総テスト数: #{total_examples}"
    puts "総失敗数: #{total_failures}"
    puts "成功率: #{((total_examples - total_failures) * 100.0 / total_examples).round(1)}%"
    puts
    
    puts "グループ別結果:"
    results.each do |result|
      success_rate = result[:examples] > 0 ? 
        ((result[:examples] - result[:failures]) * 100.0 / result[:examples]).round(1) : 
        0.0
      status = result[:failures] == 0 ? "✅" : "❌"
      puts "  #{status} #{result[:name].ljust(30)}: #{result[:examples]}個中 #{result[:failures]}個失敗 (成功率: #{success_rate}%)"
    end
    
    puts
    puts "=" * 80
    if total_failures == 0
      puts "✅ すべてのテストが成功しました！"
    elsif total_failures.to_f / total_examples < 0.05
      puts "🔶 ほぼすべてのテストが成功しています (95%以上)"
    else
      puts "⚠️ 一部のテストが失敗しています"
    end
    puts "=" * 80
  end
end

# サブセットテストも実行
class SubsetTest
  def run
    puts "\n" + "=" * 80
    puts "主要機能のサンプルテスト"
    puts "=" * 80
    puts

    require 'japanese_address_parser'
    
    test_cases = [
      # 基本的なケース
      { address: "東京都港区芝公園4-2-8", expected_level: 3 },
      { address: "大阪府大阪市北区梅田1-1-1", expected_level: 3 },
      
      # 正規化が必要なケース
      { address: "東京都港区芝１－２－３", expected_level: 3 },
      { address: "東京都渋谷区澁谷1-1-1", expected_level: 3 },
      
      # 郡を含むケース
      { address: "埼玉県比企郡滑川町福田750-1", expected_level: 3 },
      
      # 京都の通り名
      { address: "京都府京都市中京区寺町通御池上る上本能寺前町488番地", expected_level: 3 }
    ]
    
    success = 0
    failure = 0
    
    test_cases.each do |test|
      begin
        result = JapaneseAddressParser.call(test[:address])
        level = result.level
        
        if level >= test[:expected_level]
          puts "✅ #{test[:address]}"
          puts "   → レベル: #{level} (期待値: #{test[:expected_level]}以上)"
          success += 1
        else
          puts "❌ #{test[:address]}"
          puts "   → レベル: #{level} (期待値: #{test[:expected_level]})"
          failure += 1
        end
      rescue => e
        puts "❌ #{test[:address]}"
        puts "   → エラー: #{e.message}"
        failure += 1
      end
    end
    
    puts
    puts "結果: #{success}/#{test_cases.size} 成功"
  end
end

if __FILE__ == $0
  # テストランナー実行
  runner = TestRunner.new
  runner.run
  
  # サブセットテスト実行
  subset = SubsetTest.new
  subset.run
end