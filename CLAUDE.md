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