# frozen_string_literal: true

# Port of: https://github.com/geolonia/normalize-japanese-addresses/blob/49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e/src/lib/utils.ts
# Upstream: @geolonia/normalize-japanese-addresses v3.1.3

module JapaneseAddressParser
  # 出力 metadata 用に、VO から余分なフィールドを取り除いたコピー（Hash）を作る。
  module Utils
    module_function

    # JS: removeCitiesFromPrefecture(pref)
    #   if (!pref) return undefined
    #   const newPref = { ...pref }; delete newPref.cities; return newPref
    # Data.define はフィールドを削除できないので、to_h でキー付き Hash 化してから
    # cities キーを除く（JS の Omit<SinglePrefecture, 'cities'> 相当）。
    def remove_cities_from_prefecture(pref)
      return if pref.nil?

      hash = pref.to_h
      hash.delete(:cities)
      hash
    end

    # JS: removeExtraFromMachiAza(machiAza)
    #   if (!machiAza) return undefined
    #   const newMachiAza = { ...machiAza }; delete newMachiAza.csv_ranges; return newMachiAza
    def remove_extra_from_machi_aza(machi_aza)
      return if machi_aza.nil?

      hash = machi_aza.to_h
      hash.delete(:csv_ranges)
      hash
    end
  end
  public_constant :Utils
end
