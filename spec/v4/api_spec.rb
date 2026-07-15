# frozen_string_literal: true

require 'japanese_address_parser/v4'

# 公開エントリ V4.call / V4.call!（M6）。
# happy path と未マッチは上流同様ライブ CDN を叩く（working_agreement §1-8、:upstream_port）。
# fetch 失敗の契約（call=nil / call!=raise）は、唯一の I/O 境界である Normalize.call を
# スタブして決定的に検証する（モジュールキャッシュ・ネットワークに依存させない）。
::RSpec.describe(::JapaneseAddressParser::V4) do
  describe '.call', :upstream_port do
    let(:address) { '神奈川県横浜市港北区大豆戸町１７番地１１' }

    it 'returns a rich Address with nested value objects' do
      result = described_class.call(address, level: 3)

      expect(result).to(be_a(::JapaneseAddressParser::V4::Address))
      expect(result.full_address).to(eq(address))
      expect(result.prefecture.name).to(eq('神奈川県'))
      expect(result.city.name).to(eq('横浜市港北区'))
      expect(result.town.name).to(eq('大豆戸町'))
      expect(result.level).to(eq(3))
    end

    it 'returns a level-0 Address (not nil) when nothing matches — unmatched is not a failure' do
      result = described_class.call('あいうえお')

      expect(result).to(be_a(::JapaneseAddressParser::V4::Address))
      expect(result.prefecture).to(be_nil)
      expect(result.city).to(be_nil)
      expect(result.town).to(be_nil)
      expect(result.level).to(eq(0))
    end

    it 'resolves to level 8 (rsdt) with the default level' do
      result = described_class.call(address)

      expect(result.level).to(eq(8))
      expect(result.addr).to(eq('17-11'))
    end
  end

  describe 'fetch-failure contract (stubbed I/O boundary)' do
    let(:address) { '神奈川県横浜市港北区大豆戸町１７番地１１' }

    # V4.call! が「fetch 失敗」として握る代表例外（lib/japanese_address_parser/v4.rb の rescue 一覧に対応）。
    # Errno::ECONNREFUSED は SystemCallError のサブクラスを握れることの確認も兼ねる。
    [::SocketError, ::Errno::ECONNREFUSED, ::Net::OpenTimeout, ::Net::ReadTimeout, ::JSON::ParserError].each do |error_class|
      context "when the fetch raises #{error_class}" do
        before { allow(::JapaneseAddressParser::V4::Normalize).to(receive(:call).and_raise(error_class)) }

        it '.call returns nil' do
          expect(described_class.call(address)).to(be_nil)
        end

        it '.call! raises NormalizeError' do
          expect { described_class.call!(address) }
            .to(raise_error(::JapaneseAddressParser::NormalizeError))
        end
      end
    end

    context 'when the fetch raises a non-fetch error (programmer/config error)' do
      # 未知 URL スキーム等の設定/プログラマエラーは握り潰さず伝播させる（§1-7「fetch 失敗時のみ」）。
      before { allow(::JapaneseAddressParser::V4::Normalize).to(receive(:call).and_raise(::ArgumentError, 'Unknown URL schema: ftp:')) }

      it '.call! propagates the original error (not NormalizeError)' do
        expect { described_class.call!(address) }
          .to(raise_error(::ArgumentError, /Unknown URL schema/))
      end

      it '.call also propagates it (only NormalizeError is rescued to nil)' do
        expect { described_class.call(address) }
          .to(raise_error(::ArgumentError))
      end
    end
  end
end
