# frozen_string_literal: true

# Port of: https://github.com/geolonia/normalize-japanese-addresses/blob/49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e/src/types.ts
# Upstream: @geolonia/normalize-japanese-addresses v3.1.3
#   NormalizeResultPoint と座標変換ヘルパ（rsdtOrChibanToResultPoint は M8、
#   isNormalizeResultPoint は公開 API 検証とともに M6 で移植する）。

module JapaneseAddressParser
  module V4
    # 正規化結果の位置情報（EPSG:4326 / WGS84）。level は座標の正確さ（1:県 2:市 3:町字 8:住居表示/地番）。
    NormalizeResultPoint =
      ::Data.define(:lat, :lng, :level) do
        # Ruby 独自の補助コンストラクタ: [lng, lat] 配列（無ければ nil）から VO を作る。
        # 上流 types.ts の *ToResultPoint は VO の .point を直接受けるため逐語移植のまま残し、
        # metadata の Hash（[lng, lat] 配列）から組み立てる M6 リッチ VO 層はこのファクトリを共有する。
        def self.from_lng_lat(point, level:)
          return if point.nil?

          new(lat: point[1], lng: point[0], level: level)
        end

        # JS: isNormalizeResultPoint(obj) — 任意の値が NormalizeResultPoint の形か検証する type guard。
        # JS は object のプロパティ存在＋数値型を見る。Ruby では lat/lng/level に応答し、それらが
        # Numeric かつ level が 1/2/3/8 のいずれか、で判定する（JS↔Ruby のオブジェクトモデル差のため
        # Hash は対象外＝working_agreement §3-4。挙動は spec に固定する）。
        def self.normalize_result_point?(obj)
          return false unless obj.respond_to?(:lat) && obj.respond_to?(:lng) && obj.respond_to?(:level)
          return false unless obj.lat.is_a?(::Numeric) && obj.lng.is_a?(::Numeric) && obj.level.is_a?(::Numeric)

          [1, 2, 3, 8].include?(obj.level) # JS: validLevels = [1, 2, 3, 8]
        end
      end
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
