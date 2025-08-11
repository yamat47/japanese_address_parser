#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'japanese_address_parser'
require 'json'

# Pure Ruby実装の包括的な動作確認テスト
class ComprehensiveTest
  def initialize
    @normalizer = JapaneseAddressParser::AddressNormalizer
    @results = []
    @errors = []
  end

  def run_all_tests
    puts "=" * 80
    puts "Pure Ruby実装 - 包括的動作確認テスト"
    puts "=" * 80
    puts

    test_basic_addresses
    test_special_cases
    test_edge_cases
    test_normalization_patterns
    test_prefecture_variations
    test_city_variations
    test_town_variations
    test_number_variations
    test_kyoto_addresses
    test_error_handling

    print_summary
  end

  private

  def test_basic_addresses
    puts "【基本的な住所パターン】"
    puts "-" * 40
    
    addresses = [
      "東京都千代田区千代田1-1",
      "東京都港区芝公園4-2-8",
      "大阪府大阪市北区梅田1-1-1",
      "北海道札幌市中央区北1条西2丁目",
      "神奈川県横浜市西区みなとみらい2-2-1",
      "愛知県名古屋市中区三の丸3-1-1",
      "福岡県福岡市博多区博多駅前2-1-1",
      "京都府京都市中京区寺町通御池上る",
      "宮城県仙台市青葉区国分町3-7-1",
      "広島県広島市中区基町10-52"
    ]

    test_addresses(addresses, "基本的な住所")
  end

  def test_special_cases
    puts "\n【特殊ケース】"
    puts "-" * 40
    
    addresses = [
      # 郡を含む住所
      "埼玉県比企郡滑川町福田750-1",
      "千葉県印旛郡酒々井町中央台3-4-1",
      "愛知県愛知郡東郷町春木",
      
      # 島嶼部
      "東京都小笠原村父島",
      "沖縄県島尻郡南大東村在所",
      "鹿児島県大島郡龍郷町浦",
      
      # 政令指定都市の区
      "北海道札幌市中央区大通西",
      "神奈川県川崎市川崎区駅前本町",
      "大阪府堺市堺区南瓦町",
      
      # 特別区
      "東京都新宿区西新宿2-8-1",
      "東京都渋谷区渋谷2-21-1",
      "東京都世田谷区世田谷4-21-27"
    ]

    test_addresses(addresses, "特殊ケース")
  end

  def test_edge_cases
    puts "\n【エッジケース】"
    puts "-" * 40
    
    addresses = [
      # 旧字体・異体字
      "東京都澁谷区澁谷1-1-1",
      "神奈川県横濱市中區本町1-1",
      "大阪府大阪市北區梅田",
      
      # 表記ゆらぎ
      "茨城県つくば市天王台1-1-1",
      "茨城県ツクバ市天王台1-1-1",
      "茨城県筑波市天王台1-1-1",
      
      # ひらがな地名
      "茨城県つくばみらい市陽光台",
      "埼玉県さいたま市浦和区高砂",
      "青森県むつ市金谷",
      
      # カタカナ地名
      "北海道ニセコ町ニセコ",
      "沖縄県那覇市おもろまち4-1-1",
      
      # 長い住所
      "京都府京都市中京区寺町通御池上る上本能寺前町488番地",
      "京都府京都市上京区今出川通烏丸東入相国寺門前町701番地"
    ]

    test_addresses(addresses, "エッジケース")
  end

  def test_normalization_patterns
    puts "\n【正規化パターン】"
    puts "-" * 40
    
    addresses = [
      # 全角数字
      "東京都港区芝１－２－３",
      "東京都港区芝１丁目２番３号",
      
      # 漢数字
      "東京都港区芝一丁目二番三号",
      "東京都港区芝一－二－三",
      
      # ハイフンのバリエーション
      "東京都港区芝1ー2ー3",
      "東京都港区芝1−2−3",
      "東京都港区芝1‐2‐3",
      "東京都港区芝1–2–3",
      
      # スペースのバリエーション
      "東京都　港区　芝公園",
      "東京都 港区 芝公園",
      "東京都	港区	芝公園",
      
      # の・ノ・之のバリエーション
      "千葉県市原市八幡海岸通",
      "千葉県市原市八幡海岸通り",
      
      # ヶ・ケ・が のバリエーション
      "茨城県龍ヶ崎市",
      "茨城県龍ケ崎市",
      "茨城県龍が崎市"
    ]

    test_addresses(addresses, "正規化パターン")
  end

  def test_prefecture_variations
    puts "\n【都道府県の省略形】"
    puts "-" * 40
    
    addresses = [
      # 省略形
      "東京港区芝公園",
      "大阪大阪市北区",
      "京都京都市中京区",
      "北海道札幌市中央区",
      
      # 完全形
      "東京都港区芝公園",
      "大阪府大阪市北区",
      "京都府京都市中京区",
      
      # 特殊な都道府県
      "沖縄県那覇市",
      "鹿児島県鹿児島市",
      "和歌山県和歌山市"
    ]

    test_addresses(addresses, "都道府県バリエーション")
  end

  def test_city_variations
    puts "\n【市区町村のバリエーション】"
    puts "-" * 40
    
    addresses = [
      # 市
      "愛知県名古屋市中区",
      "北海道函館市",
      "青森県青森市",
      
      # 郡・町
      "北海道余市郡余市町",
      "青森県上北郡東北町",
      
      # 郡省略
      "青森県東北町",
      "北海道余市町",
      
      # 村
      "長野県南佐久郡南牧村",
      "東京都西多摩郡檜原村",
      
      # 特別区
      "東京都千代田区",
      "東京都中央区",
      "東京都港区"
    ]

    test_addresses(addresses, "市区町村バリエーション")
  end

  def test_town_variations
    puts "\n【町域のバリエーション】"
    puts "-" * 40
    
    addresses = [
      # 丁目
      "東京都港区芝1丁目",
      "東京都港区芝一丁目",
      "東京都港区芝１丁目",
      
      # 番地
      "東京都港区芝1-2-3",
      "東京都港区芝1番地2",
      "東京都港区芝1番2号",
      
      # 大字
      "埼玉県川越市大字小堤",
      "埼玉県川越市小堤",
      
      # 字
      "宮城県仙台市青葉区字青葉",
      "宮城県仙台市青葉区青葉",
      
      # 通り名
      "北海道札幌市中央区北1条通",
      "京都府京都市中京区河原町通"
    ]

    test_addresses(addresses, "町域バリエーション")
  end

  def test_number_variations
    puts "\n【数字表記のバリエーション】"
    puts "-" * 40
    
    addresses = [
      # アラビア数字
      "東京都港区芝公園4-2-8",
      
      # 全角アラビア数字
      "東京都港区芝公園４－２－８",
      
      # 漢数字
      "東京都港区芝公園四丁目二番八号",
      
      # 漢数字（位取り）
      "東京都千代田区九段南二十三番地",
      "東京都千代田区九段南二十三番",
      
      # 混在
      "東京都港区芝公園4丁目2番8号",
      "東京都港区芝公園四-2-8"
    ]

    test_addresses(addresses, "数字表記バリエーション")
  end

  def test_kyoto_addresses
    puts "\n【京都の通り名を含む住所】"
    puts "-" * 40
    
    addresses = [
      "京都府京都市中京区寺町通御池上る上本能寺前町488番地",
      "京都府京都市上京区今出川通烏丸東入相国寺門前町701",
      "京都府京都市中京区烏丸通御池下る虎屋町",
      "京都府京都市下京区四条通河原町西入真町",
      "京都府京都市東山区大和大路通四条下る大和町",
      "京都府京都市左京区北白川東久保町",
      "京都府京都市右京区嵯峨天龍寺造路町",
      "京都府京都市北区紫野大徳寺町",
      "京都府京都市南区西九条南田町",
      "京都府京都市伏見区深草西浦町"
    ]

    test_addresses(addresses, "京都の住所")
  end

  def test_error_handling
    puts "\n【エラーハンドリング】"
    puts "-" * 40
    
    addresses = [
      # 空文字列
      "",
      
      # nil
      nil,
      
      # 不正な住所
      "これは住所ではありません",
      "123456789",
      "abcdefg",
      
      # 存在しない都道府県
      "架空県架空市架空町",
      
      # 部分的な住所
      "東京都",
      "港区",
      "芝公園"
    ]

    addresses.each do |address|
      begin
        result = @normalizer.call(address.to_s)
        level = result['level'] || 0
        status = level > 0 ? "✅" : "⚠️"
        puts "#{status} \"#{address || 'nil'}\" -> レベル: #{level}"
        
        @results << {
          address: address,
          result: result,
          success: true,
          level: level
        }
      rescue => e
        puts "❌ \"#{address || 'nil'}\" -> エラー: #{e.message}"
        @errors << { address: address, error: e.message }
      end
    end
  end

  def test_addresses(addresses, category)
    addresses.each do |address|
      begin
        result = @normalizer.call(address)
        
        # 結果の検証
        pref = result['pref'] || ""
        city = result['city'] || ""
        town = result['town'] || ""
        addr = result['addr'] || ""
        level = result['level'] || 0
        
        # レベルに応じたステータス
        status = case level
                 when 3 then "✅"  # 町域まで特定
                 when 2 then "🔶"  # 市区町村まで特定
                 when 1 then "⚠️"  # 都道府県のみ
                 else "❌"         # 特定できず
                 end
        
        # 結果表示
        puts "#{status} #{address}"
        puts "   → 都道府県: #{pref}, 市区町村: #{city}, 町域: #{town}, 番地: #{addr} (レベル: #{level})"
        
        @results << {
          category: category,
          address: address,
          result: result,
          success: true,
          level: level
        }
      rescue => e
        puts "❌ #{address}"
        puts "   → エラー: #{e.message}"
        
        @errors << {
          category: category,
          address: address,
          error: e.message
        }
      end
    end
  end

  def print_summary
    puts "\n" + "=" * 80
    puts "【テスト結果サマリー】"
    puts "=" * 80
    
    total = @results.size + @errors.size
    success = @results.size
    errors = @errors.size
    
    # レベル別集計
    level3 = @results.count { |r| r[:level] == 3 }
    level2 = @results.count { |r| r[:level] == 2 }
    level1 = @results.count { |r| r[:level] == 1 }
    level0 = @results.count { |r| r[:level] == 0 }
    
    puts "総テスト数: #{total}"
    puts "成功: #{success} (#{(success * 100.0 / total).round(1)}%)"
    puts "エラー: #{errors} (#{(errors * 100.0 / total).round(1)}%)"
    puts
    puts "レベル別内訳:"
    puts "  レベル3（町域まで）: #{level3} (#{(level3 * 100.0 / success).round(1)}%)"
    puts "  レベル2（市区町村まで）: #{level2} (#{(level2 * 100.0 / success).round(1)}%)"
    puts "  レベル1（都道府県のみ）: #{level1} (#{(level1 * 100.0 / success).round(1)}%)"
    puts "  レベル0（特定できず）: #{level0} (#{(level0 * 100.0 / success).round(1)}%)"
    
    if @errors.any?
      puts "\n【エラー詳細】"
      puts "-" * 40
      @errors.each do |error|
        puts "- #{error[:address]}: #{error[:error]}"
      end
    end
    
    # カテゴリ別集計
    if @results.any?
      puts "\n【カテゴリ別成功率】"
      puts "-" * 40
      
      categories = @results.map { |r| r[:category] }.compact.uniq
      categories.each do |cat|
        cat_results = @results.select { |r| r[:category] == cat }
        cat_level3 = cat_results.count { |r| r[:level] >= 3 }
        cat_level2 = cat_results.count { |r| r[:level] >= 2 }
        
        puts "#{cat}:"
        puts "  総数: #{cat_results.size}"
        puts "  レベル3以上: #{cat_level3} (#{(cat_level3 * 100.0 / cat_results.size).round(1)}%)"
        puts "  レベル2以上: #{cat_level2} (#{(cat_level2 * 100.0 / cat_results.size).round(1)}%)"
      end
    end
    
    puts "\n" + "=" * 80
    overall_status = if errors == 0 && level3 > total * 0.7
                       "✅ テスト成功！Pure Ruby実装は正常に動作しています。"
                     elsif errors == 0
                       "🔶 テスト完了。一部の住所で町域まで特定できませんでした。"
                     else
                       "⚠️ テスト完了。エラーが発生しました。"
                     end
    puts overall_status
    puts "=" * 80
  end
end

# 実行
if __FILE__ == $0
  test = ComprehensiveTest.new
  test.run_all_tests
end