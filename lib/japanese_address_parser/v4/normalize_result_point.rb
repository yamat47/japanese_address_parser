# frozen_string_literal: true

# Port of: https://github.com/geolonia/normalize-japanese-addresses/blob/49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e/src/types.ts
# Upstream: @geolonia/normalize-japanese-addresses v3.1.3
#   NormalizeResultPoint と座標変換ヘルパ（rsdtOrChibanToResultPoint は M8、
#   isNormalizeResultPoint は公開 API 検証とともに M6 で移植する）。

module JapaneseAddressParser
  module V4
    # 正規化結果の位置情報（EPSG:4326 / WGS84）。level は座標の正確さ（1:県 2:市 3:町字 8:住居表示/地番）。
    NormalizeResultPoint = ::Data.define(:lat, :lng, :level)
    public_constant :NormalizeResultPoint

    # Single* VO（point は [lng, lat]）から NormalizeResultPoint を作る変換ヘルパ群。
    module ResultPoint
      module_function

      # JS: prefectureToResultPoint(pref)
      def prefecture_to_result_point(pref)
        NormalizeResultPoint.new(lat: pref.point[1], lng: pref.point[0], level: 1)
      end

      # JS: cityToResultPoint(city)
      def city_to_result_point(city)
        NormalizeResultPoint.new(lat: city.point[1], lng: city.point[0], level: 2)
      end

      # JS: machiAzaToResultPoint(machiAza) — point が無ければ undefined
      def machi_aza_to_result_point(machi_aza)
        return if machi_aza.point.nil?

        NormalizeResultPoint.new(lat: machi_aza.point[1], lng: machi_aza.point[0], level: 3)
      end

      # JS: upgradePoint(a, b) — より正確（level の大きい）方を採用する
      def upgrade_point(point_a, point_b)
        return point_b if point_a.nil?
        return point_a if point_b.nil?
        return point_a if point_a.level > point_b.level

        point_b
      end
    end
    public_constant :ResultPoint
  end
end
