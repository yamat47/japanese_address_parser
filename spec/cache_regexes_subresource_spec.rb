# frozen_string_literal: true

# M8 の level 8 データアクセス（fetchSubresource / parseSubresource / getRsdt / getChiban）。
# parse は .txt サンプルでオフライン検証、get_rsdt/get_chiban は上流同様ライブ CDN を Range 取得する。

require 'japanese_address_parser/cache_regexes'

::RSpec.describe(::JapaneseAddressParser::CacheRegexes) do
  describe '.parse_subresource' do
    it 'drops the first line, then builds SingleRsdt rows (header has blk_num)' do
      data = <<~TXT
        メタ行（先頭1行は捨てる）
        blk_num,rsdt_num,rsdt_num2,lng,lat
        10,8,,139.697,35.659
        1,2,3,,
      TXT

      rsdts = described_class.__send__(:parse_subresource, data)

      expect(rsdts.map(&:class).uniq).to(eq([::JapaneseAddressParser::Data::SingleRsdt]))
      # 空欄は Ruby の CSV では nil（JS の Papa.parse は '' ）。rsdt_to_string は両方を落とすので挙動は同値。
      expect(rsdts[0]).to(have_attributes(blk_num: '10', rsdt_num: '8', rsdt_num2: nil, point: [139.697, 35.659]))
      expect(rsdts[1]).to(have_attributes(rsdt_to_string: '1-2-3', point: nil))
    end

    it 'builds SingleChiban rows when the header has prc_num1' do
      data = <<~TXT
        メタ行
        prc_num1,prc_num2,prc_num3,lng,lat
        100,,,139.7,35.6
      TXT

      chibans = described_class.__send__(:parse_subresource, data)

      expect(chibans[0]).to(have_attributes(prc_num1: '100', chiban_to_string: '100', point: [139.7, 35.6]))
    end
  end

  describe '.get_rsdt', :upstream_port do
    let(:api)         { described_class.get_prefectures                      }
    let(:api_version) { api.meta.updated                                     }
    let(:tokyo)       { api.data.find { |pref| pref.pref == '東京都' }          }
    let(:shibuya)     { tokyo.cities.find { |city| city.city_name == '渋谷区' } }
    let(:dogenzaka) do
      described_class.get_towns(tokyo, shibuya, api_version).data.find { |town| town.machi_aza_name == '道玄坂一丁目' }
    end

    it 'range-fetches 住居表示 rows and includes 街区10-住居8 (道玄坂1-10-8)' do
      rsdts = described_class.get_rsdt(tokyo, shibuya, dogenzaka, api_version)

      expect(rsdts).to(all(be_a(::JapaneseAddressParser::Data::SingleRsdt)))
      expect(rsdts).to(include(have_attributes(blk_num: '10', rsdt_num: '8')))
    end

    it 'returns [] when the town has no 住居表示 range' do
      no_rsdt_town = ::JapaneseAddressParser::Data::SingleMachiAza.from_json('machiaza_id' => '0000000', 'oaza_cho' => 'x')

      expect(described_class.get_rsdt(tokyo, shibuya, no_rsdt_town, api_version)).to(eq([]))
    end
  end
end
