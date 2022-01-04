# frozen_string_literal: true

require_relative '../../lib/japanese_address_parser/models/prefecture'

::FactoryBot.define do
  factory :prefecture, class: '::JapaneseAddressParser::Models::Prefecture' do
    code { '01' }
    name { '北海道' }
    name_kana { 'ホッカイドウ' }
    name_romaji { 'HOKKAIDO' }

    initialize_with do
      new(code: code, name: name, name_kana: name_kana, name_romaji: name_romaji)
    end
  end
end
