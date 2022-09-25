# frozen_string_literal: true

target :lib do
  signature 'sig'

  check 'lib'
  ignore 'lib/japanese_address_parser/csv_parser.rb'

  configure_code_diagnostics(::Steep::Diagnostic::Ruby.strict)
end

target :test do
  signature 'sig'

  check 'spec'

  configure_code_diagnostics(::Steep::Diagnostic::Ruby.strict)
end
