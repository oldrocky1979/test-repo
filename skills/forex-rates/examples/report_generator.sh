#!/bin/bash
# 示例：生成外汇分析报告
# 演示如何使用 Forex Rates Skill 生成分析报告

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GET_RATES="$SCRIPT_DIR/../get_rates.sh"

# 获取实时数据
echo "正在获取实时外汇数据..."
forex_data=$($GET_RATES --json)

# 解析数据
eur_usd=$(echo "$forex_data" | jq -r '.rates.EUR_USD')
gbp_usd=$(echo "$forex_data" | jq -r '.rates.GBP_USD')
usd_jpy=$(echo "$forex_data" | jq -r '.rates.USD_JPY')
usd_cny=$(echo "$forex_data" | jq -r '.rates.USD_CNY')
timestamp=$(echo "$forex_data" | jq -r '.timestamp')

# 生成报告
cat << EOF
# 📊 外汇市场分析报告

**报告时间**：$timestamp  
**数据来源**：Alpha Vantage（实时）

---

## 💱 主要货币对汇率

| 货币对 | 汇率 | 说明 |
|--------|------|------|
| **EUR/USD** | $eur_usd | 欧元/美元 |
| **GBP/USD** | $gbp_usd | 英镑/美元 |
| **USD/JPY** | $usd_jpy | 美元/日元 |
| **USD/CNY** | $usd_cny | 美元/人民币 |

---

## 📈 市场分析

### 欧元/美元 (EUR/USD)
- 当前汇率：$eur_usd
- 分析：$(echo "scale=2; $eur_usd > 1.15" | bc | grep -q 1 && echo "欧元走强" || echo "美元走强")

### 英镑/美元 (GBP/USD)
- 当前汇率：$gbp_usd
- 分析：$(echo "scale=2; $gbp_usd > 1.33" | bc | grep -q 1 && echo "英镑走强" || echo "美元走强")

### 美元/日元 (USD/JPY)
- 当前汇率：$usd_jpy
- 分析：$(echo "scale=0; $usd_jpy > 158" | bc | grep -q 1 && echo "日元走弱" || echo "日元走强")

---

## 💡 交易建议

**短线策略**：
- 关注主要货币对波动
- 设置止损位
- 控制仓位

**中线策略**：
- 关注央行政策
- 跟踪经济数据
- 分散投资

---

**免责声明**：本报告仅供参考，不构成投资建议。外汇交易有风险，投资需谨慎。
EOF

echo ""
echo "报告生成完成！"
