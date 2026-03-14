# HEARTBEAT.md

## 📅 定时任务配置

### 定时推送任务

| 时间 | 任务 | 频率 | 内容 |
|------|------|------|------|
| 00:05 | server_report | 每天 | **服务器报告 + Tokens 用量&价格**（本地 + 新加坡） |
| 08:00 | morning_report | 每天 | **新闻+Skills 汇总**（4 领域各 5 条 + 分析） |
| 09:00 | forex_stock_9am | 工作日 | 外汇分析 + A 股分析推送 |
| 12:00 | stock_12pm | 工作日 | A 股早盘回顾分析 |
| 15:00 | forex_3pm | 工作日 | 外汇欧洲盘开盘前分析 |
| 15:40 | stock_340pm | 工作日 | A 股收盘分析 |
| 20:00 | forex_8pm | 工作日 | 美洲盘开盘分析 |

### 数据收集任务（每 4 小时）
| 时间 | 任务 | 内容 |
|------|------|------|
| 00:00, 04:00, 08:00, 12:00, 16:00, 20:00 | collect_news | 收集 4 领域新闻缓存 |
| 00:30, 04:30, 08:30, 12:30, 16:30, 20:30 | collect_skills | 收集 Skills 信息缓存 |

### 🚨 紧急新闻监控（每 30 分钟）
| 时间 | 任务 | 内容 |
|------|------|------|
| 07:00-23:00 每 30 分钟 | breaking_news_monitor | 检查重大新闻并立即推送 |

**紧急推送触发条件：**
- 战争/军事冲突、重大自然灾害（7 级 + 地震）
- 金融危机的（股市暴跌>5%、银行危机）
- 重大政策发布（国务院、央行、美联储）
- AI 重大突破、革命性技术发布
- 新疫情爆发等公共卫生事件

**静默时段：** 23:00-07:00（极端紧急除外）

### 配置文件
- **Cron 配置**: `/home/admin/.openclaw/workspace/crontab.txt`
- **执行脚本**: 
  - `/home/admin/.openclaw/workspace/scripts/scheduled_tasks.sh` (基础任务)
  - `/home/admin/.openclaw/workspace/scripts/daily_morning_push.sh` (早间推送)
  - `/home/admin/.openclaw/workspace/scripts/collect_news.sh` (新闻收集)
  - `/home/admin/.openclaw/workspace/scripts/collect_skills.sh` (Skills 收集)
- **日志文件**: `/home/admin/.openclaw/workspace/logs/cron.log`
- **数据目录**: `/home/admin/.openclaw/workspace/data/`

### 推送设置
- **账号**: `bot-2` (当前对话机器人)
- **目标用户**: `user:ou_c051a3ac336ce444b19011d44bbd7ff1`
- **频道**: Feishu

### 早间报告详情
- **新闻分类**: 全球时事、科技前沿、人工智能、金融经济（各 5 条）
- **Skills 推荐**: 热门技能 + 新发现技能
- **特色**: 带 AI 分析和见解

### 其他检查项
- 检查系统资源是否正常
- 检查是否有未处理的错误日志
- 检查定时任务执行日志
