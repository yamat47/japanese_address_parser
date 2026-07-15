# frozen_string_literal: true

target :lib do
  signature 'sig'

  check 'lib'

  configure_code_diagnostics(::Steep::Diagnostic::Ruby.strict)
end

target :test do
  signature 'sig'

  check 'spec'

  configure_code_diagnostics(::Steep::Diagnostic::Ruby.strict)
end
