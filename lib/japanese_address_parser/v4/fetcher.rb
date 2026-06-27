# frozen_string_literal: true

# Port of: https://github.com/geolonia/normalize-japanese-addresses/blob/49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e/src/main-node.ts
# Upstream: @geolonia/normalize-japanese-addresses v3.1.3
#   (requestHandlers / fetchOrReadFile — __internals.fetch の Node 実装)

require 'net/http'
require 'uri'
require 'json'
require 'japanese_address_parser/version'
require 'japanese_address_parser/v4/config'

module JapaneseAddressParser
  module V4
    # 正規化に必要なデータを取得する唯一の I/O 境界（JS main-node.ts の fetchOrReadFile）。
    # http(s) は Net::HTTP、file:// とローカルパスはファイル読みで取得する。
    module Fetcher
      # 取得結果。JS の FetchResponseLike `{ json(), text(), ok }` に対応する。
      # body は UTF-8 の生文字列、ok は取得成功フラグ。
      Response =
        ::Data.define(:body, :ok) do
          # JS: json: async () => JSON.parse(contents.toString('utf-8'))
          def json
            ::JSON.parse(body)
          end

          # JS: text: async () => contents.toString('utf-8')
          def text
            body
          end
        end
      public_constant :Response

      # User-Agent のコメント部で自己申告する本 gem の homepage。
      HOMEPAGE_URL = 'https://github.com/yamat47/japanese_address_parser'
      private_constant :HOMEPAGE_URL

      # リクエスト時の User-Agent。
      #
      # 【意図的な逐語移植の例外 / 将来も維持すること】
      # 上流 main-node.ts は `'normalize-japanese-addresses/0.1 (+https://github.com/geolonia/...)'`
      # を送る。しかし本 gem は上流 JS とは別の Ruby 実装であり、配信元（japanese-addresses-v2 の
      # CDN）から見たクライアントを正確に名乗るべきなので、**あえて本 gem を名乗る**ように変更している。
      # これは working_agreement §3-1（文字列の逐語コピー）の意図的な例外であり、§3-2 の「改善しない」
      # にも抵触しない（ネットワーク上の自己申告であって正規化ロジックではない）。
      # 将来の忠実移植レビュー（/simplify 等）でこれを上流の文字列へ「戻さない」こと。
      USER_AGENT = "japanese_address_parser/#{::JapaneseAddressParser::VERSION} (+#{HOMEPAGE_URL})"
      public_constant :USER_AGENT

      module_function

      # JS: fetchOrReadFile(input, options) — `__internals.fetch = fetchOrReadFile`
      #   const fileURL = new URL(`${config.japaneseAddressesApi}${input}`)
      #   protocol が http(s) → http、file → file、その他 → throw
      # offset/length は両方そろったときのみ Range 部分取得になる（上流の判定そのまま）。
      def fetch(input, offset: nil, length: nil)
        url = "#{V4.config.japanese_addresses_api}#{input}"

        if url.start_with?('http://', 'https://')
          http_request(url, offset, length)
        elsif url.start_with?('file://')
          # JS: decodeURI(fileURL.pathname)。file:// を剥がしてパーセントデコードする。
          read_file(::URI::DEFAULT_PARSER.unescape(url.sub(%r{\Afile://}, '')), offset, length)
        elsif url.match?(%r{\A[a-zA-Z][a-zA-Z0-9+.\-]*://})
          # http(s)/file 以外のスキームは上流同様に拒否する（JS: throw `Unknown URL schema: ...`）。
          raise(::ArgumentError, "Unknown URL schema: #{url[/\A[a-zA-Z][a-zA-Z0-9+.\-]*/]}:")
        else
          # スキーム無しのローカルパスも第一級サポートする（working_agreement §1-5。上流 JS には無い）。
          read_file(url, offset, length)
        end
      end

      # JS: requestHandlers.http
      def http_request(url, offset, length)
        # 日本語等の非 ASCII を含むパスを new URL 相当にエンコードしてから解析する。
        uri = ::URI.parse(::URI::DEFAULT_PARSER.escape(url))
        # JS: if (config.geoloniaApiKey) fileURL.search = `?geolonia-api-key=${...}`
        uri.query = "geolonia-api-key=#{V4.config.geolonia_api_key}" if V4.config.geolonia_api_key

        request = ::Net::HTTP::Get.new(uri)
        request['User-Agent'] = USER_AGENT
        # JS: headers['Range'] = `bytes=${o.offset}-${o.offset + o.length - 1}`
        request['Range'] = "bytes=#{offset}-#{offset + length - 1}" unless offset.nil? || length.nil?

        response =
          ::Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.is_a?(::URI::HTTPS)) do |http|
            http.request(request)
          end

        body = (response.body || '').dup.force_encoding(::Encoding::UTF_8)
        # JS: Response.ok は 2xx（206 Partial Content を含む）。Net::HTTPSuccess が同じ範囲。
        Response.new(body: body, ok: response.is_a?(::Net::HTTPSuccess))
      end

      # JS: requestHandlers.file
      def read_file(path, offset, length)
        if offset.nil? || length.nil?
          # JS: contents = await f.readFile(); ok = true
          Response.new(body: ::File.read(path, encoding: 'UTF-8'), ok: true)
        else
          # JS: Buffer.alloc(length); read(contents, 0, length, offset); ok = bytesRead === length
          # offset から length バイトを部分読みする。読めたバイト数が length 未満なら ok=false。
          # （JS は不足分をゼロ埋めするが、Ruby は読めた分のみ返す。ok で不足を表すのは同じ。）
          chunk =
            ::File.open(path, 'rb') do |file|
              file.seek(offset)
              file.read(length)
            end
          chunk = (chunk || '').dup.force_encoding(::Encoding::UTF_8)
          Response.new(body: chunk, ok: chunk.bytesize == length)
        end
      end

      private_class_method :http_request, :read_file
    end
    public_constant :Fetcher
  end
end
