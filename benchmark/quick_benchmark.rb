#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'benchmark'
require 'japanese_address_parser'

# 簡易パフォーマンステスト
puts 'Japanese Address Parser 簡易ベンチマーク'
puts '=' * 50

addresses = [
  '東京都千代田区千代田1-1',
  '大阪府大阪市北区梅田1-1-1',
  '京都府京都市中京区寺町通御池上る',
  '北海道札幌市中央区北1条西2丁目',
  '福岡県福岡市博多区博多駅前2-1-1'
]

normalizer = JapaneseAddressParser::AddressNormalizer

# ウォームアップ
print 'ウォームアップ中...'
addresses.each { |addr| normalizer.call(addr) }
puts ' 完了'

puts
puts '実行時間測定（各住所を10回処理）:'
puts '-' * 50

Benchmark.bm(35) do |x|
  # Pure Ruby実装（デフォルト）
  x.report('Pure Ruby:') do
    10.times do
      addresses.each { |addr| normalizer.call(addr) }
    end
  end

  # JavaScript実装（比較用）
  begin
    x.report('JavaScript:') do
      10.times do
        addresses.each { |addr| normalizer.call_with_javascript(addr) }
      end
    end
  rescue StandardError => e
    puts "JavaScript実装エラー: #{e.message}"
  end
end

puts
puts '個別住所の処理時間（平均）:'
puts '-' * 50

addresses.first(3).each do |address|
  ruby_time = Benchmark.realtime do
    10.times { normalizer.call(address) }
  end
  
  print "#{address.ljust(35)}: "
  puts "#{(ruby_time * 100).round(2)} ms"
end

puts
puts 'ベンチマーク完了'