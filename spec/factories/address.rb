# frozen_string_literal: true

require_relative '../../lib/japanese_address_parser/models/address'

::FactoryBot.define do
  factory :address, class: '::JapaneseAddressParser::Models::Address' do
    prefecture
    city
    town
    full_address { "#{prefecture&.name}#{city&.name}#{town&.name}1-1" }

    initialize_with do
      new(full_address: full_address, prefecture: prefecture, city: city, town: town)
    end
  end
end
