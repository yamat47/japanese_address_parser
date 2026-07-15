# frozen_string_literal: true

# Port of test/main/main.test.ts (basic tests)。上流同様ライブ CDN を叩く（working_agreement §1-8）。
# level 8（rsdt）ケースを含め全ケースを検証する。比較は assertMatchCloseTo 相当の match_close_to。

require 'japanese_address_parser'
require_relative 'support/match_close_to'

::RSpec.describe(::JapaneseAddressParser, :upstream_port) do
  subject(:normalize) { described_class }

  describe 'level resolution for 神奈川県横浜市港北区大豆戸町１７番地１１' do
    let(:address) { '神奈川県横浜市港北区大豆戸町１７番地１１' }

    it 'resolves to level 1 when level: 1' do
      expect(normalize.call(address, level: 1)).to(match_close_to(pref: '神奈川県', level: 1))
    end

    it 'resolves to level 2 when level: 2' do
      expect(normalize.call(address, level: 2)).to(match_close_to(pref: '神奈川県', city: '横浜市港北区', level: 2))
    end

    it 'resolves to level 3 when level: 3' do
      expect(normalize.call(address, level: 3)).to(match_close_to(pref: '神奈川県', city: '横浜市港北区', town: '大豆戸町', other: '17-11', level: 3))
    end
  end

  it 'gets level 2 with 神奈川県横浜市港北区' do
    expect(normalize.call('神奈川県横浜市港北区', level: 3)).to(match_close_to(pref: '神奈川県', city: '横浜市港北区', level: 2))
  end

  it 'gets level 1 with 神奈川県' do
    expect(normalize.call('神奈川県', level: 3)).to(match_close_to(pref: '神奈川県', level: 1))
  end

  it 'gets level 1 with 神奈川県あいうえお市' do
    expect(normalize.call('神奈川県あいうえお市')).to(match_close_to(pref: '神奈川県', level: 1))
  end

  it 'gets level 2 with 東京都港区あいうえお' do
    expect(normalize.call('東京都港区あいうえお')).to(match_close_to(pref: '東京都', city: '港区', level: 2))
  end

  it 'gets level 0 with あいうえお' do
    expect(normalize.call('あいうえお')).to(match_close_to(other: 'あいうえお', level: 0))
  end

  describe '東京都江東区豊洲一丁目2-27 のパターンテスト (level 8)' do
    addresses = ['東京都江東区豊洲1丁目2-27', '東京都江東区豊洲 1丁目2-27', '東京都江東区豊洲 1-2-27', '東京都 江東区 豊洲 1-2-27', '東京都江東区豊洲 １ー２ー２７', '東京都江東区豊洲 一丁目2-27', '江東区豊洲 一丁目2-27']
    addresses.each do |address|
      it address do
        expect(normalize.call(address)).to(match_close_to(pref: '東京都', city: '江東区', town: '豊洲一丁目', addr: '2-27', level: 8, point: { lat: 35.661166758, lng: 139.793685144, level: 8 }))
      end
    end
  end

  describe '丁目以降の半角・全角・漢数字の番地正規化' do
    it 'normalizes イ-prefixed addr remainder' do
      expect(normalize.call('東京都町田市木曽東四丁目１４ーイ２２ ジオロニアマンション')).to(match_close_to(other: '14-イ22 ジオロニアマンション'))
    end

    it 'normalizes full-width alnum addr remainder' do
      expect(normalize.call('東京都町田市木曽東四丁目１４ーＡ２２ ジオロニアマンション')).to(match_close_to(other: '14-A22 ジオロニアマンション'))
    end

    it 'normalizes kanji-numeral addr remainder' do
      expect(normalize.call('東京都町田市木曽東四丁目一四━Ａ二二 ジオロニアマンション')).to(match_close_to(other: '14-A22 ジオロニアマンション'))
    end

    it 'resolves a kanji-numeral chome (東京都江東区豊洲 四-2-27)' do
      expect(normalize.call('東京都江東区豊洲 四-2-27')).to(match_close_to(town: '豊洲四丁目'))
    end
  end

  # 上流 main.test.ts の対になる level 8 パターン。上流の期待 point.level は 8 ではなく 2
  # （rsdt 座標が無く市の代表点へフォールバックする上流クセ）をそのまま移植する。
  describe '石川県七尾市藤橋町亥45番地1 のパターンテスト (level 8)' do
    addresses = ['石川県七尾市藤橋町亥45番地1', '石川県七尾市藤橋町亥四十五番地1', '石川県七尾市藤橋町 亥 四十五番地1', '石川県七尾市藤橋町 亥 45-1', '七尾市藤橋町 亥 45-1']
    addresses.each do |address|
      it address do
        expect(normalize.call(address)).to(match_close_to(pref: '石川県', city: '七尾市', town: '藤橋町亥', addr: '45-1', level: 8, point: { lat: 37.043108, lng: 136.967296, level: 2 }))
      end
    end
  end

  it 'handles unicode (NFKD) normalization' do
    address = '茨城県つくば市筑穂１丁目１０−４'.unicode_normalize(:nfkd)
    expect(normalize.call(address).city.name).to(eq('つくば市'))
  end

  it 'does not convert kanji numerals in the remainder when the town name is undetermined' do
    result = normalize.call('北海道滝川市一の坂町西')
    expect(result).to(match_close_to(level: 2, other: '一の坂町西'))
    expect(result.town).to(be_nil)
  end

  describe '丁目の数字だけあるときは「一丁目」まで補充する' do
    it 'fills 小石川1 to 小石川一丁目' do
      expect(normalize.call('東京都文京区小石川1')).to(match_close_to(town: '小石川一丁目', other: ''))
    end

    it 'fills 小石川1ビル名 to 小石川一丁目 with the remainder kept' do
      expect(normalize.call('東京都文京区小石川1ビル名')).to(match_close_to(town: '小石川一丁目', other: 'ビル名'))
    end
  end

  describe '旧漢字対応' do
    [
      { label: '亞 -> 亜', addresses: %w[宮城県大崎市古川大崎東亞 宮城県大崎市古川大崎東亜], expected: { town: '古川大崎字東亜', level: 3 } },
      { label: '澤 -> 沢', addresses: %w[東京都西多摩郡奥多摩町海沢 東京都西多摩郡奥多摩町海澤], expected: { town: '海澤', level: 3 } },
      { label: '麩 -> 麸', addresses: %w[愛知県津島市池麩町 愛知県津島市池麸町], expected: { town: '池麸町', level: 3 } },
      { label: '驒 -> 騨', addresses: %w[岐阜県飛驒市 岐阜県飛騨市], expected: { city: '飛騨市', level: 2 } }
    ].each do |data|
      it data[:label] do
        data[:addresses].each do |address|
          expect(normalize.call(address)).to(match_close_to(**data[:expected]))
        end
      end
    end
  end

  it '柿碕町|柿さき町' do
    %w[愛知県安城市柿さき町 愛知県安城市柿碕町].each do |address|
      expect(normalize.call(address)).to(match_close_to(town: '柿碕町', level: 3))
    end
  end

  describe '漢数字の小字のケース' do
    it '愛知県豊田市西丹波町三五十' do
      expect(normalize.call('愛知県豊田市西丹波町三五十')).to(match_close_to(town: '西丹波町', other: '三五十', level: 3))
    end

    it '広島県府中市栗柄町名字八五十2459（小字以降は無視される）' do
      expect(normalize.call('広島県府中市栗柄町名字八五十2459')).to(match_close_to(town: '栗柄町', other: '名字八五十2459', level: 3))
    end
  end
end
