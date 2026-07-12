# frozen_string_literal: true

# Port of test/main/metadata.test.ts。上流同様ライブ CDN を叩く（:upstream_port）。
# prefecture/city/machi_aza は level 3 で揃うのでアクティブ。rsdt は level 8 のため M8 まで pending。

require 'japanese_address_parser/v4'

::RSpec.describe(::JapaneseAddressParser::V4, :upstream_port) do
  describe 'metadata of 渋谷区道玄坂1-10-8' do
    subject(:metadata) { described_class.call('渋谷区道玄坂1-10-8').metadata }

    it 'exposes input/prefecture/city/machi_aza (level 3 data) and leaves chiban nil' do
      expect(metadata.input).to(eq('渋谷区道玄坂1-10-8'))

      # prefecture は cities を除いた Hash（remove_cities_from_prefecture）。
      expect(metadata.prefecture[:code]).to(eq(130_001))
      expect(metadata.prefecture[:pref]).to(eq('東京都'))
      expect(metadata.prefecture[:pref_k]).to(eq('トウキョウト'))
      expect(metadata.prefecture[:pref_r]).to(eq('Tokyo'))
      expect(metadata.prefecture).not_to(have_key(:cities))

      # city は SingleCity VO のまま。
      expect(metadata.city.code).to(eq(131_130))
      expect(metadata.city.city).to(eq('渋谷区'))
      expect(metadata.city.city_k).to(eq('シブヤク'))
      expect(metadata.city.city_r).to(eq('Shibuya-ku'))

      # machi_aza は csv_ranges を除いた Hash（remove_extra_from_machi_aza）。
      expect(metadata.machi_aza[:oaza_cho]).to(eq('道玄坂'))
      expect(metadata.machi_aza[:oaza_cho_k]).to(eq('ドウゲンザカ'))
      expect(metadata.machi_aza[:oaza_cho_r]).to(eq('Dogenzaka'))
      expect(metadata.machi_aza[:chome_n]).to(eq(1))

      expect(metadata.chiban).to(be_nil)
    end

    it 'exposes rsdt (level 8) — pending until M8' do
      pending('level 8 (rsdt) — enabled in M8')
      expect(metadata.rsdt.blk_num).to(eq('10'))
      expect(metadata.rsdt.rsdt_num).to(eq('8'))
    end
  end

  describe 'metadata of 渋谷区道玄坂1-10-8 with level: 2' do
    subject(:metadata) { described_class.call('渋谷区道玄坂1-10-8', level: 2).metadata }

    it 'sets prefecture/city but leaves machi_aza/rsdt/chiban nil' do
      expect(metadata.input).to(eq('渋谷区道玄坂1-10-8'))
      expect(metadata.prefecture).not_to(be_nil)
      expect(metadata.city).not_to(be_nil)
      expect(metadata.machi_aza).to(be_nil)
      expect(metadata.rsdt).to(be_nil)
      expect(metadata.chiban).to(be_nil)
    end
  end
end
