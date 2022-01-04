# frozen_string_literal: true

require_relative '../../lib/japanese_address_parser/models/city'

::FactoryBot.define do
  factory :city, class: '::JapaneseAddressParser::Models::City' do
    code { '01101' }
    name { '札幌市中央区' }
    name_kana { 'サッポロシチュウオウク' }
    name_romaji { 'SAPPORO SHI CHUO KU' }
    prefecture_code { '01' }

    initialize_with do
      new(code: code, name: name, name_kana: name_kana, name_romaji: name_romaji, prefecture_code: prefecture_code)
    end
  end
end
