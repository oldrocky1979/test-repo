#!/bin/bash
# 示例：基础用法
# 演示如何使用 Forex Rates Skill

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GET_RATES="$SCRIPT_DIR/get_rates.sh"

echo "========================================"
echo "  Forex Rates Skill - 基础用法示例"
echo "========================================"
echo ""

# 示例 1：获取所有货币对（JSON 格式）
echo "1. 获取所有主要货币对（JSON 格式）："
echo "----------------------------------------"
$GET_RATES --json | jq '.rates'
echo ""

# 示例 2：获取所有货币对（表格格式）
echo "2. 获取所有主要货币对（表格格式）："
echo "----------------------------------------"
$GET_RATES --table
echo ""

# 示例 3：获取单个货币对
echo "3. 获取单个货币对（EUR/USD）："
echo "----------------------------------------"
$GET_RATES EUR USD
echo ""

# 示例 4：获取单个货币对（表格格式）
echo "4. 获取单个货币对（表格格式）："
echo "----------------------------------------"
$GET_RATES --table GBP USD
echo ""

echo "========================================"
echo "  示例完成！"
echo "========================================"
