# frozen_string_literal: true

require 'spec_helper'

# JavaScript実装との互換性を確認するテスト
RSpec.describe 'JavaScript互換性' do
  let(:normalizer) { JapaneseAddressParser::AddressNormalizer }

  describe '失敗している主要な住所の確認' do
    # 先ほど失敗していた住所を重点的にテスト
    failing_addresses = [
      # 北海道の複合地名
      { address: '北海道札幌市中央区北3条西6-1', expected_town: '北三条西' },
      { address: '北海道札幌市中央区北1条西2丁目', expected_town: '北一条西' },
      
      # 千葉県
      { address: '千葉県千葉市中央区市場町1-1', expected_town: '市場町' },
      
      # 愛知県
      { address: '愛知県名古屋市中区三の丸3-1-2', expected_town: '三の丸' },
      
      # 三重県
      { address: '三重県津市広明町13', expected_town: '広明町' },
      
      # 愛媛県
      { address: '愛媛県松山市一番町4-4-2', expected_town: '一番町' },
      
      # 岐阜県
      { address: '岐阜県岐阜市藪田南2-1-1', expected_town: '薮田南' }
    ]

    failing_addresses.each do |test_case|
      it "#{test_case[:address]}を正しく解析できる" do
        result_ruby = normalizer.call(test_case[:address])
        result_js = normalizer.call_with_javascript(test_case[:address])
        
        # Ruby実装とJavaScript実装が一致することを確認
        expect(result_ruby['pref']).to eq(result_js['pref'])
        expect(result_ruby['city']).to eq(result_js['city'])
        expect(result_ruby['town']).to eq(result_js['town'])
        expect(result_ruby['level']).to eq(result_js['level'])
        
        # 町域レベルまで認識できていることを確認
        expect(result_ruby['level']).to be >= 3
        
        # 期待される町域名が含まれることを確認（部分一致でもOK）
        if test_case[:expected_town]
          expect(result_ruby['town']).to include(test_case[:expected_town])
        end
      end
    end
  end
  
  describe '正規化処理の互換性' do
    it '全角数字を含む住所を正しく処理できる' do
      addresses = [
        '東京都港区芝１－２－３',
        '東京都港区芝４丁目'
      ]
      
      addresses.each do |address|
        result_ruby = normalizer.call(address)
        result_js = normalizer.call_with_javascript(address)
        
        expect(result_ruby['town']).to eq(result_js['town'])
      end
    end
    
    it '旧字体を含む住所を正しく処理できる' do
      addresses = [
        '東京都澁谷区澁谷1-1-1',
        '神奈川県横濱市中區本町1-1'
      ]
      
      addresses.each do |address|
        result_ruby = normalizer.call(address)
        result_js = normalizer.call_with_javascript(address)
        
        expect(result_ruby['city']).to eq(result_js['city'])
      end
    end
  end
end