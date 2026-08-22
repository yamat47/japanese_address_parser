# frozen_string_literal: true

target :lib do
  signature 'sig'

  check 'lib'

  library 'csv', 'json', 'net-http', 'socket', 'uri'

  configure_code_diagnostics(::Steep::Diagnostic::Ruby.strict)
end
