# frozen_string_literal: true

require 'spec_helper'
require 'japanese_address_parser/compatibility/js_compatibility_checker'

RSpec.describe(JapaneseAddressParser::Compatibility::JsCompatibilityChecker) do
  let(:checker) { described_class.new }

  describe '#check_single_address' do
    it '単一の住所をチェックできる' do
      checker.check_single_address('東京都港区芝公園4-2-8')
      results = checker.instance_variable_get(:@results)
      
      expect(results).not_to(be_empty)
      expect(results.first[:address]).to(eq('東京都港区芝公園4-2-8'))
      expect(results.first).to(have_key(:ruby_result))
      expect(results.first).to(have_key(:js_result))
      expect(results.first).to(have_key(:differences))
      expect(results.first).to(have_key(:compatible))
    end

    it 'エラーが発生した場合もハンドリングできる' do
      allow(checker).to(receive(:normalize_with_ruby)).and_raise(StandardError, 'Ruby error')
      
      checker.check_single_address('東京都港区芝公園4-2-8')
      results = checker.instance_variable_get(:@results)
      
      expect(results).not_to(be_empty)
      expect(results.first[:ruby_result]).to(eq({ 'error' => 'Ruby error' }))
    end
  end

  describe '#normalize_with_ruby' do
    it 'Ruby実装で住所を正規化できる' do
      result = checker.normalize_with_ruby('東京都港区芝公園4-2-8')
      
      expect(result).to(be_a(Hash))
      expect(result['pref']).to(eq('東京都'))
      expect(result['city']).to(eq('港区'))
    end

    it 'エラーが発生した場合はエラー情報を返す' do
      allow(JapaneseAddressParser::AddressNormalizer).to(receive(:call))
        .and_raise(StandardError, 'Normalization error')
      
      result = checker.normalize_with_ruby('東京都港区芝公園4-2-8')
      
      expect(result).to(eq({ 'error' => 'Normalization error' }))
    end
  end

  describe '#normalize_with_javascript' do
    it 'JavaScript実装で住所を正規化できる' do
      result = checker.normalize_with_javascript('東京都港区芝公園4-2-8')
      
      expect(result).to(be_a(Hash))
      # JavaScriptの実装が利用可能な場合
      if result['error'].nil?
        expect(result['pref']).to(eq('東京都'))
        expect(result['city']).to(eq('港区'))
      end
    end

    it 'エラーが発生した場合はエラー情報を返す' do
      allow(JapaneseAddressParser::AddressNormalizer).to(receive(:call_with_javascript))
        .and_raise(StandardError, 'JS error')
      
      result = checker.normalize_with_javascript('東京都港区芝公園4-2-8')
      
      expect(result).to(eq({ 'error' => 'JS error' }))
    end
  end

  describe '#find_differences' do
    it '同じ結果の場合は差分がない' do
      result1 = {
        'pref' => '東京都',
        'city' => '港区',
        'town' => '芝公園',
        'addr' => '4-2-8',
        'level' => 3,
        'lat' => 35.658581,
        'lng' => 139.745433
      }
      result2 = result1.dup
      
      differences = checker.find_differences(result1, result2)
      
      expect(differences).to(be_empty)
    end

    it '異なる結果の場合は差分を検出する' do
      result1 = {
        'pref' => '東京都',
        'city' => '港区',
        'town' => '芝公園',
        'addr' => '4-2-8',
        'level' => 3
      }
      result2 = {
        'pref' => '東京都',
        'city' => '港区',
        'town' => '芝公園4丁目',
        'addr' => '2-8',
        'level' => 3
      }
      
      differences = checker.find_differences(result1, result2)
      
      expect(differences).not_to(be_empty)
      expect(differences['town']).to(eq({ ruby: '芝公園', javascript: '芝公園4丁目' }))
      expect(differences['addr']).to(eq({ ruby: '4-2-8', javascript: '2-8' }))
    end

    it '緯度経度は小数点以下6桁で比較する' do
      result1 = { 'lat' => 35.6585812345, 'lng' => 139.7454339876 }
      result2 = { 'lat' => 35.6585814567, 'lng' => 139.7454341234 }
      
      differences = checker.find_differences(result1, result2)
      
      expect(differences).to(be_empty)
    end

    it 'nilの値も適切に比較する' do
      result1 = { 'town' => nil, 'addr' => '4-2-8' }
      result2 = { 'town' => '芝公園', 'addr' => '4-2-8' }
      
      differences = checker.find_differences(result1, result2)
      
      expect(differences['town']).to(eq({ ruby: nil, javascript: '芝公園' }))
    end
  end

  describe '#check_compatibility' do
    it 'デフォルトのテスト住所で互換性チェックを実行できる' do
      results = checker.check_compatibility(
        ['東京都千代田区千代田1-1', '大阪府大阪市北区梅田1-1-1']
      )
      
      expect(results).to(be_an(Array))
      expect(results.length).to(eq(2))
      
      results.each do |result|
        expect(result).to(have_key(:address))
        expect(result).to(have_key(:ruby_result))
        expect(result).to(have_key(:js_result))
        expect(result).to(have_key(:differences))
        expect(result).to(have_key(:compatible))
      end
    end
  end

  describe '#generate_report' do
    before do
      # テスト用の結果を設定
      checker.instance_variable_set(:@results, [
        {
          address: '東京都港区芝公園4-2-8',
          ruby_result: { 'pref' => '東京都', 'city' => '港区' },
          js_result: { 'pref' => '東京都', 'city' => '港区' },
          differences: {},
          compatible: true
        },
        {
          address: '京都府京都市中京区',
          ruby_result: { 'pref' => '京都府', 'city' => '京都市中京区' },
          js_result: { 'pref' => '京都府', 'city' => '京都市' },
          differences: { 'city' => { ruby: '京都市中京区', javascript: '京都市' } },
          compatible: false
        }
      ])
    end

    it 'レポートを生成できる' do
      report = checker.generate_report
      
      expect(report).to(include('JavaScript互換性チェックレポート'))
      expect(report).to(include('総テスト数: 2'))
      expect(report).to(include('互換: 1 (50.0%)'))
      expect(report).to(include('非互換: 1'))
      expect(report).to(include('差異が検出された住所:'))
      expect(report).to(include('京都府京都市中京区'))
    end

    it '全て互換性がある場合のレポート' do
      checker.instance_variable_set(:@results, [
        {
          address: '東京都港区芝公園4-2-8',
          ruby_result: { 'pref' => '東京都' },
          js_result: { 'pref' => '東京都' },
          differences: {},
          compatible: true
        }
      ])
      
      report = checker.generate_report
      
      expect(report).to(include('互換: 1 (100.0%)'))
      expect(report).to(include('非互換: 0'))
      expect(report).not_to(include('差異が検出された住所:'))
    end
  end

  describe '#export_to_csv' do
    let(:csv_file) { 'spec/tmp/compatibility_test.csv' }

    before do
      FileUtils.mkdir_p('spec/tmp')
      checker.instance_variable_set(:@results, [
        {
          address: '東京都港区芝公園4-2-8',
          ruby_result: { 'pref' => '東京都', 'city' => '港区', 'town' => '芝公園' },
          js_result: { 'pref' => '東京都', 'city' => '港区', 'town' => '芝公園' },
          differences: {},
          compatible: true
        }
      ])
    end

    after do
      FileUtils.rm_f(csv_file)
    end

    it 'CSVファイルに結果を出力できる' do
      checker.export_to_csv(csv_file)
      
      expect(File.exist?(csv_file)).to(be(true))
      
      csv_content = CSV.read(csv_file, headers: true)
      expect(csv_content.headers).to(include('住所', '互換性', 'Ruby都道府県', 'JS都道府県'))
      expect(csv_content[0]['住所']).to(eq('東京都港区芝公園4-2-8'))
      expect(csv_content[0]['互換性']).to(eq('○'))
    end
  end

  describe 'TEST_ADDRESSES' do
    it 'テスト用住所リストが定義されている' do
      expect(described_class::TEST_ADDRESSES).to(be_an(Array))
      expect(described_class::TEST_ADDRESSES).not_to(be_empty)
      expect(described_class::TEST_ADDRESSES).to(include('東京都千代田区千代田1-1'))
    end
  end
end