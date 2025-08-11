# frozen_string_literal: true

require 'spec_helper'

RSpec.describe(JapaneseAddressParser::Normalizers::Core::Extensions::PrefectureMatcher) do
  describe '.process' do
    it '完全な都道府県名を認識する' do
      result = described_class.process('東京都港区芝公園')
      expect(result[:pref]).to(eq('東京都'))
      expect(result[:pref_code]).to(eq('13'))
      expect(result[:remaining]).to(eq('港区芝公園'))
      expect(result[:matched]).to(be(true))
    end

    it '都道府県の省略形を認識する' do
      result = described_class.process('東京港区芝公園')
      expect(result[:pref]).to(eq('東京都'))
      expect(result[:pref_code]).to(eq('13'))
      expect(result[:remaining]).to(eq('港区芝公園'))
      expect(result[:matched]).to(be(true))
    end

    it '北海道を認識する' do
      result = described_class.process('北海道札幌市中央区')
      expect(result[:pref]).to(eq('北海道'))
      expect(result[:pref_code]).to(eq('01'))
      expect(result[:remaining]).to(eq('札幌市中央区'))
      expect(result[:matched]).to(be(true))
    end

    it '京都府を認識する' do
      result = described_class.process('京都府京都市中京区')
      expect(result[:pref]).to(eq('京都府'))
      expect(result[:pref_code]).to(eq('26'))
      expect(result[:remaining]).to(eq('京都市中京区'))
      expect(result[:matched]).to(be(true))
    end

    it '京都の省略形を認識する' do
      result = described_class.process('京都京都市中京区')
      expect(result[:pref]).to(eq('京都府'))
      expect(result[:pref_code]).to(eq('26'))
      expect(result[:remaining]).to(eq('京都市中京区'))
      expect(result[:matched]).to(be(true))
    end

    it '大阪府を認識する' do
      result = described_class.process('大阪府大阪市北区')
      expect(result[:pref]).to(eq('大阪府'))
      expect(result[:pref_code]).to(eq('27'))
      expect(result[:remaining]).to(eq('大阪市北区'))
      expect(result[:matched]).to(be(true))
    end

    it '大阪の省略形を認識する' do
      result = described_class.process('大阪大阪市北区')
      expect(result[:pref]).to(eq('大阪府'))
      expect(result[:pref_code]).to(eq('27'))
      expect(result[:remaining]).to(eq('大阪市北区'))
      expect(result[:matched]).to(be(true))
    end

    it '認識できない都道府県の場合' do
      result = described_class.process('架空県架空市')
      expect(result[:pref]).to(eq(''))
      expect(result[:pref_code]).to(eq(''))
      expect(result[:remaining]).to(eq('架空県架空市'))
      expect(result[:matched]).to(be(false))
    end

    it '空文字列の場合' do
      result = described_class.process('')
      expect(result[:pref]).to(eq(''))
      expect(result[:pref_code]).to(eq(''))
      expect(result[:remaining]).to(eq(''))
      expect(result[:matched]).to(be(false))
    end

    it '先頭に余分な文字がある場合は認識しない' do
      result = described_class.process('日本東京都港区')
      expect(result[:pref]).to(eq(''))
      expect(result[:matched]).to(be(false))
    end
  end

  describe '.preload' do
    it 'データをプリロードできる' do
      expect(described_class.preload).to(be(true))
    end
  end

  describe '.normalize' do
    it 'パイプライン互換インターフェース' do
      result = described_class.normalize('東京都港区芝公園')
      expect(result).to(eq('東京都港区芝公園'))
    end
  end
end