D = Steep::Diagnostic

target :lib do
  signature "sig"

  check "lib"
  ignore "lib/japanese_address_parser/csv_parser.rb"

  configure_code_diagnostics(D::Ruby.strict)       # `strict` diagnostics setting
end

target :test do
  signature "sig"

  check "spec"

  configure_code_diagnostics(D::Ruby.strict)       # `strict` diagnostics setting
end
