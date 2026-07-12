# frozen_string_literal: true

# Port of: https://github.com/geolonia/normalize-japanese-addresses/blob/49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e/src/lib/cacheRegexes.ts
# Upstream: @geolonia/normalize-japanese-addresses v3.1.3
#   level 0-3 部分のみ。rsdt/chiban（getRsdt/getChiban/fetchSubresource/parseSubresource）は M8 で実装する。

require 'set'
require 'lru_redux'
require 'japanese_address_parser/v4/config'
require 'japanese_address_parser/v4/fetcher'
require 'japanese_address_parser/v4/dict'
require 'japanese_address_parser/v4/kan2num'
require 'japanese_address_parser/v4/japanese_numeral'
require 'japanese_address_parser/v4/data/prefecture_api'
require 'japanese_address_parser/v4/data/machi_aza_api'

module JapaneseAddressParser
  module V4
    # データ取得・キャッシュ・正規表現パターン生成（cacheRegexes.ts）。
    # JS の `^`/`$`（m フラグ無し）は文字列先頭/末尾なので、生成パターンでは `\A`/`\z` に翻訳する
    # （working_agreement §3-6）。スレッド安全性は考慮しない（§1-6）。
    module CacheRegexes
      # 「○○町」の省略エイリアス。JS では SingleMachiAza に originalTown を生やした部分オブジェクト。
      # machi_aza_name は oaza_cho（町を除いた名前）を返す（chome/koaza は持たない）。
      TownAlias =
        ::Data.define(:machiaza_id, :point, :oaza_cho, :original_town) do
          # JS: machiAzaName(town) 相当。エイリアスは oaza_cho（町を除いた名前）のみを持つ。
          def machi_aza_name
            oaza_cho
          end
        end
      public_constant :TownAlias

      module_function

      # JS: const cache = new LRUCache({ max: currentConfig.cacheSize })
      # 町字 regex パターンのみ LRU でキャッシュする（working_agreement §1-8）。
      def cache
        @cache ||= ::LruRedux::Cache.new(V4.config.cache_size)
      end

      # JS: fetchFromCache(key, fetcher)
      def fetch_from_cache(key)
        cached = cache[key]
        return cached unless cached.nil?

        data = yield
        cache[key] = data
        data
      end

      # モジュールレベルのキャッシュをすべて破棄する。
      # JS は test ファイルごとに別プロセスでモジュール状態が新鮮になる（プロセス分離）が、
      # Ruby/RSpec は 1 プロセス共有のため、`japanese_addresses_api` を切り替える際の明示的な
      # リセット手段を提供する（runtime でデータ源を変えるユーザにも有用。working_agreement §1-6）。
      def reset!
        @cache = nil
        @cached_prefectures = nil
        @cached_prefecture_patterns = nil
        @cached_same_named_prefecture_city_regex_patterns = nil
        @cached_city_patterns = nil
        @cached_towns = nil
        nil
      end

      # JS: getPrefectures()
      def get_prefectures
        return @cached_prefectures unless @cached_prefectures.nil?

        response = Fetcher.fetch('.json') # ja.json
        cache_prefectures(Data::PrefectureApi.from_json(response.json))
      end

      # JS: cachePrefectures(data)
      def cache_prefectures(data)
        @cached_prefectures = data
      end

      # JS: getPrefectureRegexPatterns(api)
      def get_prefecture_regex_patterns(api)
        return @cached_prefecture_patterns if @cached_prefecture_patterns

        @cached_prefecture_patterns =
          api.data.map do |pref|
            # JS: pref.pref.replace(/(都|道|府|県)$/, '') — 末尾の都府県が抜けた住所に対応（$ → \z）
            pref_name = pref.pref.sub(/(都|道|府|県)\z/, '')
            # JS: `^${_pref}(都|道|府|県)?`（^ → \A）
            [pref, "\\A#{pref_name}(都|道|府|県)?"]
          end
      end

      # JS: getCityRegexPatterns(pref)
      def get_city_regex_patterns(pref)
        cached = cached_city_patterns[pref.code]
        return cached unless cached.nil?

        # JS: cities.sort((a, b) => cityName(a).length - cityName(b).length)
        # 少ない文字数の地名に対してミスマッチしないよう文字数の昇順に安定ソートする。
        cities = stable_sort_by(pref.cities) { |city| city.city_name.length }

        patterns =
          cities.map do |city|
            name = city.city_name
            pattern = "\\A#{Dict.to_regex_pattern(name)}"
            if name.match?(/(町|村)\z/) # JS: name.match(/(町|村)$/)
              # JS: `^${toRegexPattern(name).replace(/(.+?)郡/, '($1郡)?')}` — 郡が省略されてるかも
              pattern = "\\A#{Dict.to_regex_pattern(name).sub(/(.+?)郡/, '(\1郡)?')}"
            end
            [city, pattern]
          end

        cached_city_patterns[pref.code] = patterns
      end

      # JS: getTowns(prefObj, cityObj, apiVersion)
      def get_towns(pref_obj, city_obj, api_version)
        pref = pref_obj.prefecture_name
        city = city_obj.city_name

        cache_key = "#{pref}-#{city}"
        cached = cached_towns[cache_key]
        return cached unless cached.nil?

        # JS: ['', encodeURI(pref), encodeURI(city) + `.json?v=${apiVersion}`].join('/')
        # 非 ASCII のパーセントエンコードは Fetcher#http_request 側で一括して行う（二重エンコード回避）
        # ため、ここでは encodeURI せず生の県名・市名を渡す。
        input = ['', pref, "#{city}.json?v=#{api_version}"].join('/')
        response = Fetcher.fetch(input)
        cached_towns[cache_key] = Data::MachiAzaApi.from_json(response.json)
      end

      # JS: getTownRegexPatterns(pref, city, apiVersion)
      def get_town_regex_patterns(pref, city, api_version)
        fetch_from_cache("#{pref.code}-#{city.code}") do
          api = get_towns(pref, city, api_version)
          pre_towns = api.data
          town_set = ::Set.new(pre_towns.map(&:machi_aza_name))
          towns = []

          is_kyoto = city.city == '京都市'

          # 「○○町」が含まれるケースへの対応。通常は「町」の省略を同義語として許容するが、
          # 「○○町」と「○○」が共存するケース・京都・漢数字を含むケースは省略を許容しない。
          pre_towns.each do |town|
            towns << town

            original_town = town.machi_aza_name
            next if original_town.index('町').nil? # JS: indexOf('町') === -1

            # JS: originalTown.replace(/(?!^町)町/g, '') — 冒頭の「町」は除外（^ → \A）
            town_abbr = original_town.gsub(/(?!\A町)町/, '')
            next if is_kyoto
            next if town_set.include?(town_abbr)
            next if town_set.include?("大字#{town_abbr}")
            next if kanji_number_followed_by_cho?(original_town)

            # エイリアスとして町なしのパターンを登録
            towns << TownAlias.new(machiaza_id: town.machiaza_id, point: town.point, oaza_cho: town_abbr, original_town: town)
          end

          # JS: towns.sort((a, b) => bLen - aLen)（大字始まりは優先度を下げる）— 文字数の降順に安定ソート
          towns = stable_sort_by(towns) { |town| -town_sort_length(town) }

          patterns =
            towns.map do |town|
              pattern = Dict.to_regex_pattern(town_pattern_source(town.machi_aza_name))
              # JS: 'originalTown' in town ? town.originalTown : town
              associated = town.is_a?(TownAlias) ? town.original_town : town
              [associated, pattern]
            end

          # X丁目 の丁目なしの数字だけ許容するため、最後に数字だけ追加する。
          towns.each do |town|
            # JS: machiAzaName(town).match(/([^一二三四五六七八九十]+)([一二三四五六七八九十]+)(丁目?)/)
            chome_match = town.machi_aza_name.match(/([^一二三四五六七八九十]+)([一二三四五六七八九十]+)(丁目?)/)
            next unless chome_match

            chome_name_part = chome_match[1]
            chome_num = chome_match[2]
            # JS: toRegexPattern(`^${chomeNamePart}(${chomeNum}|${kan2num(chomeNum)})`)（^ → \A）
            pattern = Dict.to_regex_pattern("\\A#{chome_name_part}(#{chome_num}|#{Kan2num.call(chome_num)})")
            patterns << [town, pattern]
          end

          patterns
        end
      end

      # JS: getSameNamedPrefectureCityRegexPatterns(prefApi)
      def get_same_named_prefecture_city_regex_patterns(pref_api)
        return @cached_same_named_prefecture_city_regex_patterns unless @cached_same_named_prefecture_city_regex_patterns.nil?

        pref_list = pref_api.data
        # JS: pref.pref.replace(/[都|道|府|県]$/, '') — 文字クラス（| も含む）は上流のまま（$ → \z）
        prefs = pref_list.map { |pref| pref.pref.sub(/[都|道|府|県]\z/, '') }

        patterns = []
        pref_list.each do |pref|
          pref.cities.each do |city|
            city_n = city.city_name

            # 市の名前が別の都道府県名から始まっているケース（例: 福島県石川郡石川町）を考慮する。
            prefs.each do |pref_name|
              # JS: cityN.indexOf(_prefs[j]) === 0
              patterns << ["#{pref.pref}#{city_n}", "\\A#{city_n}"] if city_n.start_with?(pref_name)
            end
          end
        end

        @cached_same_named_prefecture_city_regex_patterns = patterns
      end

      # JS: getRsdt(pref, city, town, apiVersion) — M8 で実装する。
      def get_rsdt(_pref, _city, _town, _api_version)
        raise(::NotImplementedError, 'getRsdt is implemented in M8 (level 8)')
      end

      # JS: getChiban(pref, city, town, apiVersion) — M8 で実装する。
      def get_chiban(_pref, _city, _town, _api_version)
        raise(::NotImplementedError, 'getChiban is implemented in M8 (level 8)')
      end

      # --- 内部ヘルパ ---

      # 単純 Hash キャッシュ（全件）。LRU ではない（working_agreement §1-8）。
      # JS: cachedCityPatterns（pref.code をキーにした市区町村パターンの全件 Hash キャッシュ）
      def cached_city_patterns
        @cached_city_patterns ||= {}
      end

      # JS: cachedTowns（"県-市" をキーにした町字一覧の全件 Hash キャッシュ）
      def cached_towns
        @cached_towns ||= {}
      end

      # JS の安定 Array.sort を再現する（Ruby の sort_by は非安定なので index でタイブレーク）。
      def stable_sort_by(list)
        list.each_with_index.sort_by { |item, index| [yield(item), index] }
            .map(&:first)
      end

      # JS: aLen（大字始まりは -2 して優先度を下げる）
      def town_sort_length(town)
        name = town.machi_aza_name
        name.start_with?('大字') ? name.length - 2 : name.length
      end

      # JS: isKanjiNumberFollewedByCho(targetTownName)（上流の関数名タイポはそのまま意図を移植）
      # 「十六町」のように漢数字と町が連結しているか。
      def kanji_number_followed_by_cho?(target_town_name)
        x_cho = target_town_name.scan(/.町/) # JS: match(/.町/g)
        return false if x_cho.empty?

        !JapaneseNumeral.find_kanji_numbers(x_cho[0]).empty?
      end

      # JS: getTownRegexPatterns 内の machiAzaName(town).replace(...) チェーン（toRegexPattern へ渡す前段）。
      def town_pattern_source(name)
        name
          # 横棒を含む場合（流通センター等）に対応
          .gsub(/[-－﹣−‐⁃‑‒–—﹘―⎯⏤ーｰ─━]/, '[-－﹣−‐⁃‑‒–—﹘―⎯⏤ーｰ─━]')
          .gsub(/大?字/, '(大?字)?')
          # 町丁目に含まれる数字を正規表現へ。ABR データの全角数字（第１地割 等）にも一致させる。
          .gsub(/([壱一二三四五六七八九十]+|[１２３４５６７８９０]+)(丁目?|番(町|丁)|条|軒|線|(の|ノ)町|地割|号)/) do |match|
            expand_town_number(match)
          end
      end

      # JS: getTownRegexPatterns 内の数字パターン展開コールバック。
      def expand_town_number(match)
        suffix = /(丁目?|番(町|丁)|条|軒|線|(の|ノ)町|地割|号)/
        patterns = []
        patterns << match.sub(suffix, '') # 漢数字（接尾辞を除く）

        if match.match?(/\A壱/) # JS: match.match(/^壱/)（^ → \A）
          patterns.push('一', '1', '１')
        else
          num = match
                .gsub(/([一二三四五六七八九十]+)/) { |m| Kan2num.call(m) }
                .gsub(/([１２３４５６７８９０]+)/) { |m| JapaneseNumeral.kanji2number(m).to_s }
                .sub(suffix, '')
          patterns << num # 半角アラビア数字
        end

        # 注: この正規表現は上のよく似た接尾辞パターンとは異なる（JS のコメントどおり）。
        "(#{patterns.join('|')})((丁|町)目?|番(町|丁)|条|軒|線|の町?|地割|号|[-－﹣−‐⁃‑‒–—﹘―⎯⏤ーｰ─━])"
      end

      private_class_method :cached_city_patterns, :cached_towns, :stable_sort_by, :town_sort_length, :kanji_number_followed_by_cho?, :town_pattern_source, :expand_town_number
    end
    public_constant :CacheRegexes
  end
end
