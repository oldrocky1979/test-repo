#!/bin/bash
# Forex Rates Library - 外汇汇率函数库
# 版本：v1.0.0
# 用法：source forex_lib.sh

# Alpha Vantage API 配置
AV_API_KEY="${ALPHA_VANTAGE_API_KEY:-}"
AV_BASE_URL="https://www.alphavantage.co/query"

# 获取单个货币对汇率
# 用法：get_forex_rate "EUR" "USD"
# 返回：汇率值（失败返回 0）
get_forex_rate() {
    local from="$1"
    local to="$2"
    local max_retries=3
    local retry=0
    
    if [ -z "$AV_API_KEY" ]; then
        echo "0"
        return 1
    fi
    
    while [ $retry -lt $max_retries ]; do
        local response=$(curl -s "$AV_BASE_URL?function=CURRENCY_EXCHANGE_RATE&from_currency=$from&to_currency=$to&apikey=$AV_API_KEY" 2>/dev/null)
        
        local rate=$(echo "$response" | jq -r '.["Realtime Currency Exchange Rate"]["5. Exchange Rate"]' 2>/dev/null)
        
        if [ "$rate" != "null" ] && [ -n "$rate" ] && [ "$rate" != "" ]; then
            echo "$rate"
            return 0
        fi
        
        retry=$((retry + 1))
        sleep 2
    done
    
    echo "0"
    return 1
}

# 获取汇率（带更新时间）
# 用法：get_forex_rate_with_time "EUR" "USD"
# 返回：汇率 | 更新时间
get_forex_rate_with_time() {
    local from="$1"
    local to="$2"
    
    if [ -z "$AV_API_KEY" ]; then
        echo "0|"
        return 1
    fi
    
    local response=$(curl -s "$AV_BASE_URL?function=CURRENCY_EXCHANGE_RATE&from_currency=$from&to_currency=$to&apikey=$AV_API_KEY" 2>/dev/null)
    
    local rate=$(echo "$response" | jq -r '.["Realtime Currency Exchange Rate"]["5. Exchange Rate"]' 2>/dev/null)
    local time=$(echo "$response" | jq -r '.["Realtime Currency Exchange Rate"]["6. Last Refreshed"]' 2>/dev/null)
    
    if [ "$rate" != "null" ] && [ -n "$rate" ]; then
        echo "$rate|$time"
        return 0
    fi
    
    echo "0|"
    return 1
}

# 获取所有主要货币对
# 用法：get_all_forex_rates
# 返回：JSON 格式数据
get_all_forex_rates() {
    if [ -z "$AV_API_KEY" ]; then
        echo '{"error": "ALPHA_VANTAGE_API_KEY not configured"}'
        return 1
    fi
    
    local eur_usd=$(get_forex_rate "EUR" "USD"); sleep 1.2
    local gbp_usd=$(get_forex_rate "GBP" "USD"); sleep 1.2
    local usd_jpy=$(get_forex_rate "USD" "JPY"); sleep 1.2
    local usd_cny=$(get_forex_rate "USD" "CNY"); sleep 1.2
    local aud_usd=$(get_forex_rate "AUD" "USD"); sleep 1.2
    local usd_hkd=$(get_forex_rate "USD" "HKD")
    
    cat << EOF
{
  "source": "Alpha Vantage",
  "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')",
  "rates": {
    "EUR_USD": $eur_usd,
    "GBP_USD": $gbp_usd,
    "USD_JPY": $usd_jpy,
    "USD_CNY": $usd_cny,
    "AUD_USD": $aud_usd,
    "USD_HKD": $usd_hkd
  }
}
EOF
}

# 货币转换
# 用法：convert_currency 100 "EUR" "USD"
# 返回：转换后的金额
convert_currency() {
    local amount="$1"
    local from="$2"
    local to="$3"
    
    local rate=$(get_forex_rate "$from" "$to")
    
    if [ "$rate" = "0" ]; then
        echo "0"
        return 1
    fi
    
    local result=$(echo "scale=2; $amount * $rate" | bc)
    echo "$result"
}

# 检查 API 状态
# 用法：check_api_status
# 返回：0=正常，1=异常
check_api_status() {
    if [ -z "$AV_API_KEY" ]; then
        return 1
    fi
    
    local test=$(get_forex_rate "EUR" "USD")
    
    if [ "$test" = "0" ]; then
        return 1
    fi
    
    return 0
}

# 打印汇率表格
# 用法：print_forex_table
print_forex_table() {
    printf "%-10s %-12s %-25s\n" "货币对" "汇率" "更新时间"
    printf "%-10s %-12s %-25s\n" "--------" "--------" "-------------------------"
    
    local eur=$(get_forex_rate_with_time "EUR" "USD")
    local gbp=$(get_forex_rate_with_time "GBP" "USD")
    local jpy=$(get_forex_rate_with_time "USD" "JPY")
    local cny=$(get_forex_rate_with_time "USD" "CNY")
    
    IFS='|' read -r eur_rate eur_time <<< "$eur"
    IFS='|' read -r gbp_rate gbp_time <<< "$gbp"
    IFS='|' read -r jpy_rate jpy_time <<< "$jpy"
    IFS='|' read -r cny_rate cny_time <<< "$cny"
    
    printf "%-10s %-12s %-25s\n" "EUR/USD" "$eur_rate" "${eur_time:-N/A}"
    printf "%-10s %-12s %-25s\n" "GBP/USD" "$gbp_rate" "${gbp_time:-N/A}"
    printf "%-10s %-12s %-25s\n" "USD/JPY" "$jpy_rate" "${jpy_time:-N/A}"
    printf "%-10s %-12s %-25s\n" "USD/CNY" "$cny_rate" "${cny_time:-N/A}"
}

# 示例用法
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    echo "Forex Rates Library v1.0.0"
    echo "这是一个函数库，请使用 source 命令加载："
    echo "  source forex_lib.sh"
    echo ""
    echo "可用函数："
    echo "  get_forex_rate FROM TO          - 获取汇率"
    echo "  get_forex_rate_with_time FROM TO - 获取汇率（含时间）"
    echo "  get_all_forex_rates             - 获取所有货币对"
    echo "  convert_currency AMOUNT FROM TO - 货币转换"
    echo "  check_api_status                - 检查 API 状态"
    echo "  print_forex_table               - 打印汇率表格"
fi
