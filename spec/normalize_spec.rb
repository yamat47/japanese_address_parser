# frozen_string_literal: true

require 'japanese_address_parser/normalize'

# 上流（main.test.ts）同様、既定エンドポイント＝ライブ CDN を叩く（working_agreement §1-8）。
# 注: 緯度経度の厳密一致は検証しない。point.level（座標の正確さ）と pref/city/town/other のみ確認し、
#     座標の近似一致マッチャ整備と緯度経度検証は M7 で行う。
::RSpec.describe(::JapaneseAddressParser::Normalize, :upstream_port) do
  describe '.call' do
    let(:address) { '神奈川県横浜市港北区大豆戸町１７番地１１' }

    # 上流 main.test.ts の level 1/2/3 ケースをそのまま移植。
    context 'with 神奈川県横浜市港北区大豆戸町１７番地１１' do
      it 'normalizes to level 1' do
        result = described_class.call(address, level: 1)

        expect(result.pref).to(eq('神奈川県'))
        expect(result.level).to(eq(1))
        expect(result.point.level).to(eq(1))
      end

      it 'normalizes to level 2' do
        result = described_class.call(address, level: 2)

        expect(result.pref).to(eq('神奈川県'))
        expect(result.city).to(eq('横浜市港北区'))
        expect(result.level).to(eq(2))
        expect(result.point.level).to(eq(2))
      end

      it 'normalizes to level 3 with the address remainder' do
        result = described_class.call(address, level: 3)

        expect(result.pref).to(eq('神奈川県'))
        expect(result.city).to(eq('横浜市港北区'))
        expect(result.town).to(eq('大豆戸町'))
        expect(result.other).to(eq('17-11'))
        expect(result.level).to(eq(3))
        expect(result.point.level).to(eq(3))
      end

      it 'resolves to level 8 (rsdt) with the default level' do
        result = described_class.call(address)

        expect(result.level).to(eq(8))
        expect(result.addr).to(eq('17-11'))
      end
    end

    it 'completes an omitted prefecture when the city shares a prefecture name' do
      # 千葉市 は県名「千葉」で始まるので 千葉県 を補完する。
      result = described_class.call('千葉市中央区中央4-5-1', level: 3)

      expect(result.pref).to(eq('千葉県'))
      expect(result.city).to(eq('千葉市中央区'))
      expect(result.town).to(eq('中央四丁目'))
      expect(result.other).to(eq('5-1'))
    end

    it 'converts an arabic chome number to kanji inside the town' do
      result = described_class.call('東京都渋谷区道玄坂2-10-8', level: 3)

      expect(result.town).to(eq('道玄坂二丁目'))
      expect(result.other).to(eq('10-8'))
    end

    it 'returns level 0 when nothing matches and leaves the address in other' do
      result = described_class.call('あいうえお')

      expect(result.pref).to(be_nil)
      expect(result.level).to(eq(0))
      expect(result.other).to(eq('あいうえお'))
      expect(result.point).to(be_nil)
    end

    it 'stops at the requested level even when more could be matched' do
      result = described_class.call(address, level: 1)

      expect(result.city).to(be_nil)
      expect(result.town).to(be_nil)
    end

    describe 'metadata' do
      subject(:metadata) { described_class.call(address, level: 3).metadata }

      it 'keeps the raw input' do
        expect(metadata.input).to(eq(address))
      end

      it 'exposes prefecture as a Hash without the cities key' do
        expect(metadata.prefecture).to(be_a(::Hash))
        expect(metadata.prefecture).not_to(have_key(:cities))
      end

      it 'exposes machi_aza as a Hash without the csv_ranges key' do
        expect(metadata.machi_aza).to(be_a(::Hash))
        expect(metadata.machi_aza).not_to(have_key(:csv_ranges))
      end
    end
  end
end
