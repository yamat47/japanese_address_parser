# frozen_string_literal: true

require_relative 'lib/japanese_address_parser/version'

::Gem::Specification.new do |spec|
  spec.name = 'japanese_address_parser'
  spec.version = ::JapaneseAddressParser::VERSION
  spec.authors = ['Yamaguchi Takuya']
  spec.email = ['yamat47.thirddown@gmail.com']

  spec.summary = '後で書く'
  spec.description = '後で書く'
  spec.homepage = 'https://github.com/yamat47/japanese_address_parser'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/yamat47/japanese_address_parser'
  spec.metadata['changelog_uri'] = 'https://github.com/yamat47/japanese_address_parser/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files =
    ::Dir.chdir(::File.expand_path(__dir__)) do
      `git ls-files -z`.split("\x0").reject do |f|
        (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
      end
    end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| ::File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency('number_to_kanji')
  spec.add_development_dependency('factory_bot')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rubocop')
  spec.add_development_dependency('rubocop-rake')
  spec.add_development_dependency('rubocop-rspec')
  spec.metadata['rubygems_mfa_required'] = 'true'
end
