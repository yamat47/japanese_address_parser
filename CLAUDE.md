# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🚧 v4.0.0 リアーキテクチャ進行中

このリポジトリは現在、Node.js / `schmooze` 依存を撤去し `@geolonia/normalize-japanese-addresses` v3.1.3 を Ruby に逐語移植する **v4.0.0 リアーキテクチャ**を進めている（作業ブランチ `rearchitecture`）。

**リアーキテクチャ関連の作業を行う場合は、まず `docs/working_agreement.md` を読むこと。** そこを起点に:
- `docs/working_agreement.md` — 運用ルール・確定方針・上流の読み方（最初に読む）
- `docs/milestones.md` — 作業単位 M0〜M10（未チェックの最若番が次の作業）
- `docs/rearchitecture.md` — 設計の真実源
- `docs/upstream_mapping.md` — JS → Ruby 逐語移植対応表

以下の「Project Overview」「Architecture Overview」は**現行（v3.x・schmooze ベース）**の記述であり、リアーキ完了（M9）時に刷新される。

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