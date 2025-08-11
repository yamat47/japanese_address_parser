# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'デバッグ - 千葉県・三重県の問題' do
  let(:normalizer) { JapaneseAddressParser::AddressNormalizer }

  describe '都道府県認識の問題' do
    it '千葉県が認識できるか' do
      # 問題のある住所
      address = '千葉県千葉市中央区市場町1-1'
      
      # 各ステップの結果を確認
      puts "\n--- デバッグ: #{address} ---"
      
      # 1. 正規化パイプラインの結果を確認
      pipeline = JapaneseAddressParser::Normalizers::Pipeline
      normalized = pipeline.normalize(address)
      puts "正規化後: #{normalized}"
      
      # 2. 都道府県マッチャーの結果を確認
      pref_matcher = JapaneseAddressParser::Normalizers::Core::Extensions::PrefectureMatcher
      pref_result = pref_matcher.process(normalized)
      puts "都道府県マッチング結果: #{pref_result.inspect}"
      
      # 3. 全体の結果を確認
      result = normalizer.call(address)
      puts "最終結果: #{result.inspect}"
      
      expect(result['pref']).to eq('千葉県')
    end
    
    it '三重県が認識できるか' do
      address = '三重県津市広明町13'
      
      puts "\n--- デバッグ: #{address} ---"
      
      # 正規化パイプラインの結果を確認
      pipeline = JapaneseAddressParser::Normalizers::Pipeline
      normalized = pipeline.normalize(address)
      puts "正規化後: #{normalized}"
      
      # 都道府県マッチャーの結果を確認
      pref_matcher = JapaneseAddressParser::Normalizers::Core::Extensions::PrefectureMatcher
      pref_result = pref_matcher.process(normalized)
      puts "都道府県マッチング結果: #{pref_result.inspect}"
      
      result = normalizer.call(address)
      puts "最終結果: #{result.inspect}"
      
      expect(result['pref']).to eq('三重県')
    end
    
    it '問題のない東京都が認識できるか（比較用）' do
      address = '東京都港区芝公園4-2-8'
      
      puts "\n--- デバッグ: #{address} ---"
      
      pipeline = JapaneseAddressParser::Normalizers::Pipeline
      normalized = pipeline.normalize(address)
      puts "正規化後: #{normalized}"
      
      pref_matcher = JapaneseAddressParser::Normalizers::Core::Extensions::PrefectureMatcher
      pref_result = pref_matcher.process(normalized)
      puts "都道府県マッチング結果: #{pref_result.inspect}"
      
      result = normalizer.call(address)
      puts "最終結果: #{result.inspect}"
      
      expect(result['pref']).to eq('東京都')
    end
  end
end