# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

JapaneseAddressParser is a Ruby gem that parses Japanese addresses using the geolonia/normalize-japanese-addresses library. It requires Node.js to run as it bridges Ruby and JavaScript through the `schmooze` gem.

## Common Development Commands

### Testing
```bash
# Run all tests
bundle exec rspec

# Run a specific test file
bundle exec rspec spec/japanese_address_parser_spec.rb

# Run tests with a specific line number
bundle exec rspec spec/japanese_address_parser_spec.rb:42
```

### Linting and Type Checking
```bash
# Run RuboCop
bundle exec rubocop

# Run RuboCop with auto-fix
bundle exec rubocop -a

# Run Steep type checker
bundle exec steep check

# Run all default tasks (RSpec + RuboCop)
bundle exec rake
```

### Development Tasks
```bash
# Update parsed CSV data from geolonia/japanese-addresses
bundle exec rake japanese_address_parser:parse_csv

# Open interactive console
bin/console

# Setup development environment
bin/setup
```

## Docker Setup and Testing

### Building and Running with Docker

```bash
# Build the Docker image
docker compose build

# Start a container and enter the development environment
docker compose run --rm gemsrc sh

# Inside the container, start the Ruby console
/gemsrc # bin/console
```

### Testing the Gem Functionality

Once inside the Docker container, you can test the gem's functionality:

```ruby
# Basic address parsing
address = JapaneseAddressParser.call('東京都港区芝公園4-2-8')

# Get prefecture information
prefecture = address.prefecture
prefecture.attributes
# => {:code=>"13", :name=>"東京都", :name_kana=>"トウキョウト", :name_romaji=>"TOKYO TO"}

# Get city information
city = address.city
city.attributes
# => {:code=>"13103", :formatted_code=>"13103", :prefecture_code=>"13", :name=>"港区", :name_kana=>"ミナトク", :name_romaji=>"MINATO KU"}

# Get town information
town = address.town
town.attributes
# => {:name=>"芝公園四丁目", :name_kana=>"シバコウエン 4", :name_romaji=>"SHIBAKOEN 4", :nickname=>nil, :latitude=>"35.656459", :longitude=>"139.74764"}

# Get full address and furigana
address.full_address # => "東京都港区芝公園4-2-8"
address.furigana     # => "トウキョウトミナトクシバコウエン 4"
```

### Running Tests from Docker

If you have a running container (e.g., `japanese_address_parser-gemsrc-1`), you can execute commands from outside:

```bash
# Run a simple Ruby script
docker exec japanese_address_parser-gemsrc-1 ruby -e "require 'bundler/setup'; require 'japanese_address_parser'; puts JapaneseAddressParser.call('東京都港区芝公園4-2-8').full_address"

# Check installed dependencies
docker exec japanese_address_parser-gemsrc-1 bundle check

# Run RSpec tests
docker exec japanese_address_parser-gemsrc-1 bundle exec rspec

# Run RuboCop
docker exec japanese_address_parser-gemsrc-1 bundle exec rubocop
```

## Architecture Overview

### Core Components

1. **Address Normalization** (`lib/japanese_address_parser/address_normalizer.rb`)
   - Uses JavaScript via `schmooze` gem to call normalize-japanese-addresses
   - Handles the bridge between Ruby and Node.js

2. **Address Parsing** (`lib/japanese_address_parser/address_parser.rb`)
   - Parses normalized addresses into Prefecture, City, and Town models
   - Uses CSV data stored in `lib/japanese_address_parser/data/`

3. **Data Management**
   - CSV files in `data/` directory contain Japanese address information
   - Organized by prefecture and municipality codes
   - Updated via `rake japanese_address_parser:parse_csv`

### Testing Structure

- Uses RSpec with FactoryBot for test data generation
- Test data stored in YAML files under `spec/japanese_address_parser_spec/`
- Parallel test execution in CI (10 nodes)

### Type System

- Uses Steep for static type checking
- RBS type signatures in `/sig/` directory
- TypeProf configuration available

### JavaScript Integration

- Node modules required for address normalization
- JavaScript files located in `/js/` directory
- Managed through the schmooze gem bridge