# frozen_string_literal: true

module JapaneseAddressParser
  module AddressParser
    module PatternCreator
      # geolonia/normalize-japanese-addressesの実装を参考にしている。
      # https://github.com/geolonia/normalize-japanese-addresses/blob/6ca49c3b21cd40d2cb3118b6f38006bcf93ee10f/src/lib/dict.ts#L25
      def call(address)
        address_regexp = address.gsub(/大字南長野字幅下/, '(大字南長野|大字南長野字幅下)')
                                .gsub(/三栄町|四谷三栄町/, '(三栄町|四谷三栄町)')
                                .gsub(/鬮野川|くじ野川|くじの川/, '(鬮野川|くじ野川|くじの川)')
                                .gsub(/通り|とおり/, '(通り|とおり)')
                                .gsub(/埠頭|ふ頭/, '(埠頭|ふ頭)')
                                .gsub(/番町|番丁/, '(番町|番丁)')
                                .gsub(/大冝|大宜/, '(大冝|大宜)')
                                .gsub(/穝|さい/, '(穝|さい)')
                                .gsub(/杁|えぶり/, '(杁|えぶり)')
                                .gsub(/薭|稗|ひえ|ヒエ/, '(薭|稗|ひえ|ヒエ)')
                                .gsub(/[之ノの]/, '[之ノの]')
                                .gsub(/[ヶケが]/, '[ヶケが]')
                                .gsub(/[ヵカか力]/, '[ヵカか力]')
                                .gsub(/[ッツっつ]/, '[ッツっつ]')
                                .gsub(/[ニ二]/, '[ニ二]')
                                .gsub(/[ハ八]/, '[ハ八]')
                                .gsub(/塚|塚/, '(塚|塚)')
                                .gsub(/釜|竈/, '(釜|竈)')
                                .gsub(/條|条/, '(條|条)')
                                .gsub(/狛|拍/, '(狛|拍)')
                                .gsub(/藪|薮/, '(藪|薮)')
                                .gsub(/渕|淵/, '(渕|淵)')
                                .gsub(/エ|ヱ|え/, '(エ|ヱ|え)')
                                .gsub(/曾|曽/, '(曾|曽)')
                                .gsub(/舟|船/, '(舟|船)')
                                .gsub(/莵|菟/, '(莵|菟)')
                                .gsub(/市|巿/, '(市|巿)')

        # 「日本大通1」のように丁目を含みそうな地名のとき、含む・含まないの両方のケースを作る。
        address_regexp =
          address_regexp.gsub(/(\D*)(\d+)$/) do
            "#{::Regexp.last_match(1)}(|#{::NumberToKanji.call(Integer(::Regexp.last_match(2), 10))}丁目)$"
          end

        # 「1-2-3」のように丁目を含みそうな地名のとき、含む・含まないの両方のケースを作る。
        address_regexp =
          address_regexp.gsub(/(\D*)(\d*)-.*$/) do
            "#{::Regexp.last_match(1)}(|#{::NumberToKanji.call(Integer(::Regexp.last_match(2), 10))}丁目)$"
          end

        ::Regexp.compile("^#{address_regexp}")
      end

      module_function :call
    end
  end
end
