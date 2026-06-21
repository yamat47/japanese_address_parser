# frozen_string_literal: true

# Port of: https://github.com/geolonia/normalize-japanese-addresses/blob/49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e/src/lib/dictionaries/dictionary.ts
# Upstream: @geolonia/normalize-japanese-addresses v3.1.3

require 'japanese_address_parser/v4/dictionaries/jis_dai2'

module JapaneseAddressParser
  module V4
    module Dictionaries
      # 複数の辞書を 1 本に集約する（将来辞書を追加するためのフック）。
      # JS: export const dictionary = [jisDai2Dictionary, /* ... */].flat()
      module Dictionary
        # 各要素は { src:, dst: } の Hash。flat()（深さ 1）に合わせ flatten(1)。
        DICTIONARY = [JisDai2::DICTIONARY].flatten(1).freeze

        public_constant :DICTIONARY
      end
      public_constant :Dictionary
    end
  end
end
