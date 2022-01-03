# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

::RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'

::RuboCop::RakeTask.new

task default: %i[spec rubocop]

require_relative 'lib/japanese_address_parser/csv_parser'

namespace :japanese_address_parser do
  desc '都道府県や市区町村、その中の町の情報を更新するためのタスクです。'
  task :parse_csv do
    ::JapaneseAddressParser::CsvParser.call
  end
end
