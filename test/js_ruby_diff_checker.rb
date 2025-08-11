#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'japanese_address_parser'
require 'json'

# JavaScript実装とRuby実装の差異を検出
class JsRubyDiffChecker
  def initialize
    @normalizer = JapaneseAddressParser::AddressNormalizer
    @differences = []
  end

  def check_test_addresses
    puts "=" * 80
    puts "JavaScript実装とRuby実装の比較"
    puts "=" * 80
    puts

    # テスト対象の住所（失敗していそうなもの）
    test_addresses = [
      # 北海道の複合的な地名
      "北海道札幌市中央区北3条西6-1",
      "北海道札幌市中央区北1条西2丁目",
      "北海道札幌市中央区南3条西11丁目330-2",
      "北海道札幌市北区北24条西6丁目1-1",
      
      # 千葉県の問題のある住所
      "千葉県千葉市中央区市場町1-1",
      "千葉県印旛郡酒々井町中央台3-4-1",
      "千葉県市原市八幡海岸通",
      
      # 愛知県
      "愛知県名古屋市中区三の丸3-1-2",
      
      # 三重県
      "三重県津市広明町13",
      
      # 愛媛県
      "愛媛県松山市一番町4-4-2",
      
      # 岐阜県
      "岐阜県岐阜市藪田南2-1-1",
      "岐阜県中津川市かやの木町2-1",
      "岐阜県郡上市八幡町島谷228",
      
      # 石川県
      "石川県野々市市三納1-1",
      
      # 福井県
      "福井県敦賀市中央町2-1-1",
      "福井県三方郡美浜町郷市25-25",
      "福井県三方上中郡若狭町中央1-1",
      
      # 山梨県
      "山梨県西八代郡市川三郷町市川大門1790-3",
      
      # 長野県
      "長野県中野市三好町1-3-19",
      "長野県塩尻市大門7番町3-3",
      "長野県千曲市杭瀬下2丁目1番地",
      
      # 東京都の全角数字
      "東京都港区芝４丁目"
    ]

    test_addresses.each do |address|
      check_single_address(address)
    end

    print_report
  end

  private

  def check_single_address(address)
    begin
      # Ruby実装（Pure Ruby）
      ruby_result = @normalizer.call(address)
      
      # JavaScript実装
      js_result = @normalizer.call_with_javascript(address)
      
      # 差異チェック
      differences = compare_results(ruby_result, js_result)
      
      if differences.any?
        @differences << {
          address: address,
          ruby_result: ruby_result,
          js_result: js_result,
          differences: differences
        }
        
        puts "❌ #{address}"
        differences.each do |key, diff|
          puts "   #{key}: Ruby='#{diff[:ruby]}', JS='#{diff[:js]}'"
        end
      else
        puts "✅ #{address}"
      end
    rescue => e
      puts "⚠️ #{address} - エラー: #{e.message}"
    end
  end

  def compare_results(ruby_result, js_result)
    differences = {}
    
    # 主要フィールドを比較
    %w[pref city town addr level].each do |key|
      ruby_val = ruby_result[key]
      js_val = js_result[key]
      
      # levelは数値型の場合がある
      if key == 'level'
        ruby_val = ruby_val.to_i if ruby_val
        js_val = js_val.to_i if js_val
      end
      
      if ruby_val != js_val
        differences[key] = { ruby: ruby_val, js: js_val }
      end
    end
    
    differences
  end

  def print_report
    puts
    puts "=" * 80
    puts "差異レポート"
    puts "=" * 80
    
    if @differences.empty?
      puts "✅ すべての住所でJavaScript実装と一致しています！"
    else
      puts "❌ #{@differences.size}件の差異が見つかりました"
      puts
      
      # 差異の詳細
      @differences.each_with_index do |diff, i|
        puts "#{i + 1}. #{diff[:address]}"
        diff[:differences].each do |key, values|
          puts "   #{key}:"
          puts "     Ruby: #{values[:ruby].inspect}"
          puts "     JS:   #{values[:js].inspect}"
        end
        puts
      end
      
      # フィールド別の差異集計
      field_counts = Hash.new(0)
      @differences.each do |diff|
        diff[:differences].keys.each { |key| field_counts[key] += 1 }
      end
      
      puts "フィールド別差異件数:"
      field_counts.each do |field, count|
        puts "  #{field}: #{count}件"
      end
    end
  end
end

if __FILE__ == $0
  checker = JsRubyDiffChecker.new
  checker.check_test_addresses
end