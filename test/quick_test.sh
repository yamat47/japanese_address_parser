#!/bin/bash
# 既存テストの実行状況を確認

echo "======================================================================"
echo "既存テストスイートの実行結果"
echo "======================================================================"
echo

echo "【Models テスト】"
echo "----------------------------------------------------------------------"
bundle exec rspec spec/japanese_address_parser/models/ --format progress --no-color 2>&1 | tail -3
echo

echo "【Address Normalizer テスト】"
echo "----------------------------------------------------------------------"
bundle exec rspec spec/japanese_address_parser/address_normalizer/ --format progress --no-color 2>&1 | tail -3
echo

echo "【Normalizers Core/Inspired テスト】"
echo "----------------------------------------------------------------------"
bundle exec rspec spec/japanese_address_parser/normalizers/core/inspired/ --format progress --no-color 2>&1 | tail -3
echo

echo "【Normalizers Core/Extensions テスト】"
echo "----------------------------------------------------------------------"
bundle exec rspec spec/japanese_address_parser/normalizers/core/extensions/ --format progress --no-color 2>&1 | tail -3
echo

echo "【Normalizers Pipeline テスト】"
echo "----------------------------------------------------------------------"
bundle exec rspec spec/japanese_address_parser/normalizers/pipeline_spec.rb --format progress --no-color 2>&1 | tail -3
echo

echo "【Normalizers Pure Ruby テスト】"
echo "----------------------------------------------------------------------"
bundle exec rspec spec/japanese_address_parser/normalizers/pure_ruby_spec.rb --format progress --no-color 2>&1 | tail -3
echo

echo "======================================================================"
echo "サマリー"
echo "======================================================================"
echo "※ 大量の住所テスト（japanese_address_parser_spec.rb）は"
echo "  時間がかかるため除外しています"