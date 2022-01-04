# frozen_string_literal: true

require_relative '../../lib/japanese_address_parser/models/town'

::FactoryBot.define do
  factory :town, class: '::JapaneseAddressParser::Models::Town' do
    latitude { '43.04223' }
    longitude { '141.319722' }
    name { '旭ヶ丘一丁目' }
    name_kana { 'アサヒガオカ 1' }
    name_romaji { 'ASAHIGAOKA 1' }
    nickname { nil }

    initialize_with do
      new(latitude: latitude, longitude: longitude, name: name, name_kana: name_kana, name_romaji: name_romaji, nickname: nickname)
    end
  end
end
