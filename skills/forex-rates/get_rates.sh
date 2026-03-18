#!/bin/bash
# Forex Rates Skill - 实时外汇汇率获取
# 版本：v1.0.0
# 数据源：Alpha Vantage API（实时）

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="/home/admin/.openclaw/workspace"
DATA_DIR="$WORKSPACE/data/forex"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 加载环境变量
if [ -f "$WORKSPACE/.env" ]; then
    source "$WORKSPACE/.env"
fi

# Alpha Vantage API 配置
AV_API_KEY="${ALPHA_VANTAGE_API_KEY:-}"
AV_BASE_URL="https://www.alphavantage.co/query"

# 输出格式（json|table|text）
OUTPUT_FORMAT="json"

# 显示帮助
show_help() {
    cat << EOF
Forex Rates Skill v1.0.0 - 实时外汇汇率获取

用法：$0 [选项] [货币对]

选项:
  -h, --help          显示帮助信息
  -j, --json          JSON 格式输出（默认）
  -t, --table         表格格式输出
  -T, --text          文本格式输出
  -s, --single        获取单个货币对（需要指定 FROM TO）
  --version           显示版本号

示例:
  $0                           # 获取所有主要货币对（JSON）
  $0 --table                   # 获取所有货币对（表格格式）
  $0 EUR USD                   # 获取 EUR/USD 汇率
  $0 -s GBP USD                # 获取 GBP/USD 汇率

支持的货币对：
  EUR/USD, GBP/USD, USD/JPY, USD/CNY, AUD/USD, USD/HKD, USD/CHF, USD/CAD

数据源：Alpha Vantage API（实时更新）
API 文档：https://www.alphavantage.co/documentation/
EOF
}

# 获取单个货币对汇率（带重试）
get_currency_pair() {
    local from="$1"
    local to="$2"
    local max_retries=3
    local retry=0
    
    while [ $retry -lt $max_retries ]; do
        local response=$(curl -s "$AV_BASE_URL?function=CURRENCY_EXCHANGE_RATE&from_currency=$from&to_currency=$to&apikey=$AV_API_KEY" 2>/dev/null)
        
        local rate=$(echo "$response" | jq -r '.["Realtime Currency Exchange Rate"]["5. Exchange Rate"]' 2>/dev/null)
        local refreshed=$(echo "$response" | jq -r '.["Realtime Currency Exchange Rate"]["6. Last Refreshed"]' 2>/dev/null)
        
        if [ "$rate" != "null" ] && [ -n "$rate" ] && [ "$rate" != "" ]; then
            echo "$rate|$refreshed"
            return 0
        fi
        
        retry=$((retry + 1))
        sleep 2
    done
    
    echo "0|"
    return 1
}

# 获取所有主要货币对
get_all_rates() {
    mkdir -p "$DATA_DIR"
    
    if [ -z "$AV_API_KEY" ]; then
        echo "错误：ALPHA_VANTAGE_API_KEY 未配置" >&2
        echo "请在 ~/.openclaw/workspace/.env 中添加 API Key" >&2
        exit 1
    fi
    
    # 获取主要货币对（带延时避免限流）
    local eur_usd=$(get_currency_pair "EUR" "USD"); sleep 1.2
    local gbp_usd=$(get_currency_pair "GBP" "USD"); sleep 1.2
    local usd_jpy=$(get_currency_pair "USD" "JPY"); sleep 1.2
    local usd_cny=$(get_currency_pair "USD" "CNY"); sleep 1.2
    local aud_usd=$(get_currency_pair "AUD" "USD"); sleep 1.2
    local usd_hkd=$(get_currency_pair "USD" "HKD"); sleep 1.2
    local usd_chf=$(get_currency_pair "USD" "CHF"); sleep 1.2
    local usd_cad=$(get_currency_pair "USD" "CAD")
    
    # 解析数据
    IFS='|' read -r eur_usd_rate eur_usd_time <<< "$eur_usd"
    IFS='|' read -r gbp_usd_rate gbp_usd_time <<< "$gbp_usd"
    IFS='|' read -r usd_jpy_rate usd_jpy_time <<< "$usd_jpy"
    IFS='|' read -r usd_cny_rate usd_cny_time <<< "$usd_cny"
    IFS='|' read -r aud_usd_rate aud_usd_time <<< "$aud_usd"
    IFS='|' read -r usd_hkd_rate usd_hkd_time <<< "$usd_hkd"
    IFS='|' read -r usd_chf_rate usd_chf_time <<< "$usd_chf"
    IFS='|' read -r usd_cad_rate usd_cad_time <<< "$usd_cad"
    
    # 验证数据
    if [ "$eur_usd_rate" = "0" ] || [ "$usd_jpy_rate" = "0" ] || [ "$usd_cny_rate" = "0" ]; then
        echo "错误：API 获取数据失败，可能触及限流" >&2
        exit 1
    fi
    
    # 计算交叉汇率
    local eur_cny=$(echo "scale=4; $usd_cny_rate * $eur_usd_rate" | bc)
    local gbp_cny=$(echo "scale=4; $usd_cny_rate / $gbp_usd_rate" | bc)
    local aud_cny=$(echo "scale=4; $usd_cny_rate * $aud_usd_rate" | bc)
    
    # 输出结果
    case "$OUTPUT_FORMAT" in
        "json")
            output_json
            ;;
        "table")
            output_table
            ;;
        "text")
            output_text
            ;;
    esac
    
    # 保存到文件
    cat > "$DATA_DIR/alpha_vantage.json" << EOF
{
  "source": "Alpha Vantage (实时)",
  "timestamp": "$TIMESTAMP",
  "base": "Multiple",
  "rates": {
    "EUR_USD": $eur_usd_rate,
    "GBP_USD": $gbp_usd_rate,
    "USD_JPY": $usd_jpy_rate,
    "USD_CNY": $usd_cny_rate,
    "AUD_USD": $aud_usd_rate,
    "USD_HKD": $usd_hkd_rate,
    "USD_CHF": $usd_chf_rate,
    "USD_CAD": $usd_cad_rate,
    "EUR_CNY": $eur_cny,
    "GBP_CNY": $gbp_cny,
    "AUD_CNY": $aud_cny
  },
  "last_refreshed": "$TIMESTAMP"
}
EOF
}

# JSON 格式输出
output_json() {
    cat << EOF
{
  "source": "Alpha Vantage (实时)",
  "timestamp": "$TIMESTAMP",
  "base": "Multiple",
  "rates": {
    "EUR_USD": $eur_usd_rate,
    "GBP_USD": $gbp_usd_rate,
    "USD_JPY": $usd_jpy_rate,
    "USD_CNY": $usd_cny_rate,
    "AUD_USD": $aud_usd_rate,
    "USD_HKD": $usd_hkd_rate,
    "USD_CHF": $usd_chf_rate,
    "USD_CAD": $usd_cad_rate
  },
  "last_refreshed": "$TIMESTAMP"
}
EOF
}

# 表格格式输出
output_table() {
    printf "%-10s %-12s %-25s\n" "货币对" "汇率" "更新时间"
    printf "%-10s %-12s %-25s\n" "--------" "--------" "-------------------------"
    printf "%-10s %-12s %-25s\n" "EUR/USD" "$eur_usd_rate" "${eur_usd_time:-N/A}"
    printf "%-10s %-12s %-25s\n" "GBP/USD" "$gbp_usd_rate" "${gbp_usd_time:-N/A}"
    printf "%-10s %-12s %-25s\n" "USD/JPY" "$usd_jpy_rate" "${usd_jpy_time:-N/A}"
    printf "%-10s %-12s %-25s\n" "USD/CNY" "$usd_cny_rate" "${usd_cny_time:-N/A}"
    printf "%-10s %-12s %-25s\n" "AUD/USD" "$aud_usd_rate" "${aud_usd_time:-N/A}"
    printf "%-10s %-12s %-25s\n" "USD/HKD" "$usd_hkd_rate" "${usd_hkd_time:-N/A}"
}

# 文本格式输出
output_text() {
    echo "Forex Rates - $TIMESTAMP"
    echo "数据来源：Alpha Vantage (实时)"
    echo "--------------------------------"
    echo "EUR/USD = $eur_usd_rate"
    echo "GBP/USD = $gbp_usd_rate"
    echo "USD/JPY = $usd_jpy_rate"
    echo "USD/CNY = $usd_cny_rate"
    echo "AUD/USD = $aud_usd_rate"
    echo "USD/HKD = $usd_hkd_rate"
}

# 获取单个货币对
get_single_pair() {
    local from="$1"
    local to="$2"
    
    if [ -z "$from" ] || [ -z "$to" ]; then
        echo "错误：请指定货币对（FROM TO）" >&2
        exit 1
    fi
    
    local result=$(get_currency_pair "$from" "$to")
    IFS='|' read -r rate time <<< "$result"
    
    if [ "$rate" = "0" ]; then
        echo "错误：获取 $from/$to 汇率失败" >&2
        exit 1
    fi
    
    case "$OUTPUT_FORMAT" in
        "json")
            echo "{\"pair\": \"$from/$to\", \"rate\": $rate, \"time\": \"$time\"}"
            ;;
        "table")
            printf "%-10s %-12s %-25s\n" "$from/$to" "$rate" "${time:-N/A}"
            ;;
        "text")
            echo "$from/$to = $rate (更新时间：$time)"
            ;;
    esac
}

# 显示版本号
show_version() {
    echo "Forex Rates Skill v1.0.0"
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -j|--json)
            OUTPUT_FORMAT="json"
            shift
            ;;
        -t|--table)
            OUTPUT_FORMAT="table"
            shift
            ;;
        -T|--text)
            OUTPUT_FORMAT="text"
            shift
            ;;
        -s|--single)
            shift
            if [ $# -ge 2 ]; then
                get_single_pair "$1" "$2"
                exit 0
            else
                echo "错误：-s 需要指定货币对（FROM TO）" >&2
                exit 1
            fi
            ;;
        --version)
            show_version
            exit 0
            ;;
        *)
            # 默认获取单个货币对
            if [ $# -ge 2 ]; then
                get_single_pair "$1" "$2"
                exit 0
            else
                echo "错误：未知参数 $1" >&2
                show_help
                exit 1
            fi
            ;;
    esac
done

# 默认：获取所有货币对
get_all_rates
