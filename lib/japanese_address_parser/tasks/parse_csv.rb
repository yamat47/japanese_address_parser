# 都道府県や市区町村、その中の町の情報を更新するためのタスクです。
# 使い方:
#   $ ruby lib/japanese_address_parser/tasks/parse_csv.rb

require_relative '../csv_parser'

JapaneseAddressParser::CsvParser.call
