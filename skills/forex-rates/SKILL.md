# Forex Rates Skill - 实时外汇汇率获取

## 📊 技能说明

实时获取外汇汇率数据，支持主要货币对（EUR/USD、GBP/USD、USD/JPY、USD/CNY 等）。

**数据源**：Alpha Vantage API（实时更新，5 分钟级别）

**适用场景**：
- 定时外汇分析报告
- 投资组合汇率计算
- 跨境电商结算
- 财务数据汇总

---

## 🚀 快速开始

### 1. 配置 API Key

在 `~/.openclaw/workspace/.env` 中添加：

```bash
ALPHA_VANTAGE_API_KEY=你的 API Key
```

**获取 API Key**：https://www.alphavantage.co/support/#api-key（免费，20 秒注册）

### 2. 调用技能

```bash
# 获取所有主要货币对
/home/admin/.openclaw/workspace/skills/forex-rates/get_rates.sh

# 获取单个货币对
/home/admin/.openclaw/workspace/skills/forex-rates/get_rates.sh EUR USD

# 输出 JSON 格式
/home/admin/.openclaw/workspace/skills/forex-rates/get_rates.sh --json
```

---

## 📋 支持的货币对

| 货币对 | 代码 | 说明 |
|--------|------|------|
| **EUR/USD** | EUR USD | 欧元/美元 |
| **GBP/USD** | GBP USD | 英镑/美元 |
| **USD/JPY** | USD JPY | 美元/日元 |
| **USD/CNY** | USD CNY | 美元/人民币 |
| **AUD/USD** | AUD USD | 澳元/美元 |
| **USD/HKD** | USD HKD | 美元/港币 |
| **USD/CHF** | USD CHF | 美元/瑞郎 |
| **USD/CAD** | USD CAD | 美元/加元 |

---

## 📤 输出格式

### JSON 输出（默认）

```json
{
  "source": "Alpha Vantage (实时)",
  "timestamp": "2026-03-18 16:52:47",
  "base": "Multiple",
  "rates": {
    "EUR_USD": 1.1534,
    "GBP_USD": 1.3350,
    "USD_JPY": 158.95,
    "USD_CNY": 6.8718,
    "AUD_USD": 0.7105,
    "USD_HKD": 7.8387
  },
  "last_refreshed": "2026-03-18 16:52:55"
}
```

### 表格输出（--table）

```
货币对      汇率        更新时间
EUR/USD    1.1534     2026-03-18 16:52:45
GBP/USD    1.3350     2026-03-18 16:52:46
USD/JPY    158.95     2026-03-18 16:52:47
USD/CNY    6.8718     2026-03-18 16:52:48
```

---

## 🔧 高级用法

### 1. 在 OpenClaw Agent 中使用

```python
# 在 agent 提示词中调用
import subprocess
result = subprocess.run(['/home/admin/.openclaw/workspace/skills/forex-rates/get_rates.sh', '--json'], 
                       capture_output=True, text=True)
forex_data = json.loads(result.stdout)
```

### 2. 在 Shell 脚本中使用

```bash
#!/bin/bash
source /home/admin/.openclaw/workspace/skills/forex-rates/forex_lib.sh

# 获取 EUR/USD 汇率
eur_usd=$(get_forex_rate "EUR" "USD")
echo "EUR/USD = $eur_usd"

# 获取所有货币对
get_all_rates
```

### 3. 定时任务调用

```bash
# 每 4 小时获取一次外汇数据
0 */4 * * * /home/admin/.openclaw/workspace/skills/forex-rates/get_rates.sh >> /var/log/forex.log 2>&1
```

---

## 📁 文件结构

```
forex-rates/
├── SKILL.md              # 技能说明文档
├── get_rates.sh          # 主脚本（获取汇率）
├── forex_lib.sh          # 函数库（可被其他脚本引用）
├── config.example.sh     # 配置示例
└── examples/
    ├── basic_usage.sh    # 基础使用示例
    └── report_generator.sh  # 报告生成示例
```

---

## ⚠️ 注意事项

### API 限流

- **免费额度**：500 次/日
- **限流**：5 次/分钟
- **建议**：单次调用获取所有货币对，避免频繁调用

### 数据更新频率

- **更新频率**：实时（交易时段）
- **延迟**：1-5 分钟
- **休市**：周末和节假日数据不更新

### 错误处理

```bash
# 检查 API Key 是否配置
if [ -z "$ALPHA_VANTAGE_API_KEY" ]; then
    echo "错误：ALPHA_VANTAGE_API_KEY 未配置"
    exit 1
fi

# 检查 API 调用是否成功
result=$(get_forex_rate "EUR" "USD")
if [ "$result" = "0" ]; then
    echo "API 调用失败，使用备用数据源"
fi
```

---

## 🐛 故障排查

### 问题 1：API 调用返回 null

**原因**：API 限流（5 次/分钟）

**解决**：
```bash
# 增加调用间隔
sleep 2  # 每次调用间隔 2 秒
```

### 问题 2：ALPHA_VANTAGE_API_KEY 未找到

**解决**：
```bash
# 检查 .env 文件
cat ~/.openclaw/workspace/.env | grep ALPHA

# 重新加载环境变量
source ~/.openclaw/workspace/.env
```

### 问题 3：数据不准确

**解决**：
- 检查是否为交易时段（周末休市）
- 对比多个数据源验证
- 检查 API Key 是否正确

---

## 📞 技术支持

- **Alpha Vantage 文档**：https://www.alphavantage.co/documentation/
- **API 支持**：support@alphavantage.co
- **技能维护**：OpenClaw 社区

---

## 📝 更新日志

### v1.0.0 (2026-03-18)
- ✅ 初始版本发布
- ✅ 支持 Alpha Vantage API
- ✅ 支持 8 个主要货币对
- ✅ JSON 和表格输出格式
- ✅ 自动重试机制
- ✅ 备用数据源支持

---

**技能版本**：v1.0.0  
**最后更新**：2026-03-18  
**维护者**：OpenClaw 社区
