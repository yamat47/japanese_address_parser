# frozen_string_literal: true

require 'number_to_kanji'
require_relative './models/address'
require_relative './models/prefecture'

module JapaneseAddressParser
  module AddressParser
    def call(full_address)
      prefecture = ::JapaneseAddressParser::Models::Prefecture.all.find { |candidate| full_address.start_with?(candidate.name) }

      city_and_after = full_address.delete_prefix(prefecture.name)
      city = prefecture.cities.find { |candidate| city_and_after.start_with?(candidate.name) }

      town_and_after = city_and_after.delete_prefix(city.name)
      normalized_town_and_after = _normalize_town_and_after(town_and_after)
      town = city.towns.find { |candidate| normalized_town_and_after.start_with?(candidate.name) }

      ::JapaneseAddressParser::Models::Address.new(full_address: full_address, prefecture: prefecture, city: city, town: town)
    end

    def _normalize_town_and_after(town_and_after)
      # 全角の数字を半角に変換する。
      normalized = town_and_after.tr('０-９', '0-9')

      # ハイフンのような文字をハイフンに変換する。
      normalized = normalized.gsub(/[‐－―ー−]/, '-')

      # 「2丁目」のような表記に含まれる英数字を漢数字に変換する。
      normalized =
        normalized.gsub(/(\D*)(\d*)丁目.*/) do
          "#{::Regexp.last_match(1)}#{::NumberToKanji.call(Integer(::Regexp.last_match(2), 10))}丁目"
        end

      # 「1-2-3」のような表記を「一丁目」に変換する。
      normalized.gsub(/(\D*)(\d*)-.*$/) do
        "#{::Regexp.last_match(1)}#{::NumberToKanji.call(Integer(::Regexp.last_match(2), 10))}丁目"
      end
    end

    module_function :call, :_normalize_town_and_after
    private_class_method :_normalize_town_and_after
  end
end
