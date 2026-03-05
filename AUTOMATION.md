# 自动化工作汇报配置

## 📋 任务概览

| 任务 | 时间 | 内容 |
|------|------|------|
| 外汇交易信息 | 08:00 | 实时新闻、经济数据、市场研判 |
| OpenClaw 技能收集 | 12:00 | 新技能、分类、使用场景 |
| 外汇交易信息 | 12:00 | 实时新闻、经济数据、市场研判 |
| OpenClaw 技能收集 | 18:00 | 新技能、分类、使用场景 |

## 📁 文件结构

```
/home/admin/.openclaw/workspace/
├── scripts/
│   ├── skill-report.sh    # 技能收集脚本
│   └── forex-report.sh    # 外汇信息脚本
├── reports/                # 生成的报告
│   ├── skill-report-YYYYMMDD.md
│   └── forex-report-YYYYMMDD.md
├── logs/                   # 执行日志
│   ├── skill-report.log
│   └── forex-report.log
└── AUTOMATION.md          # 本配置文件
```

## ⏰ Cron 配置

```bash
# 查看当前任务
crontab -l

# 编辑任务
crontab -e

# 查看日志
tail -f /home/admin/.openclaw/workspace/logs/*.log
```

## 📊 汇报内容

### 技能收集
- 来源：GitHub / ClawHub / 官方文档 / 社区
- 内容：新技能发现、分类整理、使用场景

### 外汇信息
- 来源：财经新闻 / 央行公告 / 经济数据日历
- 内容：实时新闻、数据发布预告、市场研判

---
配置时间：2026-03-05
