# Forex Rates Skill - 实时外汇汇率获取

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/openclaw/openclaw)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Data Source](https://img.shields.io/badge/data-Alpha%20Vantage-orange.svg)](https://www.alphavantage.co/)

实时获取外汇汇率数据的 OpenClaw 技能，支持主要货币对（EUR/USD、GBP/USD、USD/JPY、USD/CNY 等）。

---

## ✨ 特性

- 🚀 **实时数据**：Alpha Vantage API，5 分钟级别更新
- 💰 **支持多货币对**：EUR/USD、GBP/USD、USD/JPY、USD/CNY 等 8 个主要货币对
- 📊 **多种输出格式**：JSON、表格、文本
- 🔄 **自动重试**：API 限流时自动重试
- 💾 **数据缓存**：自动保存到本地文件
- 📚 **函数库**：提供 bash 函数库供其他脚本调用

---

## 🚀 快速开始

### 1. 配置 API Key

```bash
# 在 ~/.openclaw/workspace/.env 中添加
ALPHA_VANTAGE_API_KEY=你的 API Key
```

**获取 API Key**：https://www.alphavantage.co/support/#api-key（免费，20 秒注册）

### 2. 使用技能

```bash
# 获取所有货币对（JSON 格式）
./get_rates.sh

# 获取所有货币对（表格格式）
./get_rates.sh --table

# 获取单个货币对
./get_rates.sh EUR USD

# 在脚本中使用函数库
source forex_lib.sh
rate=$(get_forex_rate "EUR" "USD")
echo "EUR/USD = $rate"
```

---

## 📋 文档

- **[SKILL.md](SKILL.md)** - 完整技能文档
- **[forex_lib.sh](forex_lib.sh)** - 函数库 API
- **[examples/](examples/)** - 使用示例

---

## 💡 使用场景

### 1. 定时推送报告

```bash
# 在 crontab 中配置
0 9 * * 1-5 /path/to/forex-rates/get_rates.sh --json | python3 send_report.py
```

### 2. 投资组合计算

```bash
source forex_lib.sh
usd_value=$(convert_currency 1000 "EUR" "USD")
echo "1000 EUR = $usd_value USD"
```

### 3. 财务数据汇总

```bash
./get_rates.sh --json | jq '.rates' > forex_rates.json
```

---

## 🔧 API 说明

### 数据源

- **提供商**：Alpha Vantage
- **更新频率**：实时（交易时段）
- **免费额度**：500 次/日
- **限流**：5 次/分钟

### 支持的货币对

| 货币对 | 代码 | 说明 |
|--------|------|------|
| EUR/USD | EUR USD | 欧元/美元 |
| GBP/USD | GBP USD | 英镑/美元 |
| USD/JPY | USD JPY | 美元/日元 |
| USD/CNY | USD CNY | 美元/人民币 |
| AUD/USD | AUD USD | 澳元/美元 |
| USD/HKD | USD HKD | 美元/港币 |
| USD/CHF | USD CHF | 美元/瑞郎 |
| USD/CAD | USD CAD | 美元/加元 |

---

## 📁 文件结构

```
forex-rates/
├── README.md               # 本文件
├── SKILL.md                # 完整技能文档
├── get_rates.sh            # 主脚本
├── forex_lib.sh            # 函数库
├── config.example.sh       # 配置示例
└── examples/
    ├── basic_usage.sh      # 基础使用示例
    └── report_generator.sh # 报告生成示例
```

---

## ⚠️ 注意事项

### API 限流

- 免费账户限制：500 次/日，5 次/分钟
- 脚本已内置延时保护（每次调用间隔 1.2 秒）
- 建议单次调用获取所有货币对

### 数据更新

- 交易时段：实时（24 小时，周末休市）
- 延迟：1-5 分钟
- 休市：周末和节假日数据不更新

---

## 🐛 故障排查

### 问题 1：API 调用返回 null

**原因**：API 限流

**解决**：等待 1 分钟后重试，或减少调用频率

### 问题 2：ALPHA_VANTAGE_API_KEY 未找到

**解决**：
```bash
# 检查 .env 文件
cat ~/.openclaw/workspace/.env | grep ALPHA

# 重新加载环境变量
source ~/.openclaw/workspace/.env
```

---

## 📝 更新日志

### v1.0.0 (2026-03-18)
- ✅ 初始版本发布
- ✅ 支持 Alpha Vantage API
- ✅ 支持 8 个主要货币对
- ✅ JSON、表格、文本输出格式
- ✅ 自动重试机制
- ✅ 函数库支持

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE)

---

## 📞 支持

- **Alpha Vantage 文档**：https://www.alphavantage.co/documentation/
- **OpenClaw 文档**：https://docs.openclaw.ai
- **社区支持**：https://discord.gg/clawd

---

**技能版本**：v1.0.0  
**最后更新**：2026-03-18  
**维护者**：OpenClaw 社区
