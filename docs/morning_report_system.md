# 早间新闻与 Skills 推送系统

## 系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                     Crontab 调度器                           │
├─────────────────────────────────────────────────────────────┤
│  每 4 小时  │ collect_news.sh    → 创建新闻收集任务标记        │
│  每 4 小时  │ collect_skills.sh  → 创建 Skills 收集任务标记    │
│  每天 8:00  │ daily_morning_push.sh → 触发 sub-agent 生成报告  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    Sub-Agent 报告生成器                       │
├─────────────────────────────────────────────────────────────┤
│  1. web_search 搜索 4 领域新闻（各 5 条）                      │
│  2. agents_list + web_search 收集 Skills                     │
│  3. 生成精美 Markdown 报告（带分析）                          │
│  4. message 工具推送至 Feishu                                │
└─────────────────────────────────────────────────────────────┘
```

## 新闻分类

| 分类 | 搜索关键词 | 数量 |
|------|-----------|------|
| 🌍 全球时事 | 国际新闻 今日热点 | 5 条 |
| 💻 科技前沿 | 科技新闻 最新发布 | 5 条 |
| 🤖 人工智能 | AI 大模型 最新进展 | 5 条 |
| 💰 金融经济 | 金融市场 股市动态 | 5 条 |

## 推送时间

- **每天 8:00** - 完整报告推送（含新闻 + Skills + 分析）
- **数据收集** - 每 4 小时自动缓存最新信息

## 文件结构

```
/home/admin/.openclaw/workspace/
├── crontab.txt                    # Crontab 配置
├── HEARTBEAT.md                   # 任务配置说明
├── scripts/
│   ├── scheduled_tasks.sh         # 基础任务脚本
│   ├── daily_morning_push.sh      # 早间推送触发器
│   ├── collect_news.sh            # 新闻收集脚本
│   └── collect_skills.sh          # Skills 收集脚本
├── data/
│   ├── news/                      # 新闻缓存数据
│   └── skills/                    # Skills 缓存数据
├── logs/
│   ├── cron.log                   # Cron 执行日志
│   ├── scheduled_tasks.log        # 任务日志
│   ├── news_collection.log        # 新闻收集日志
│   ├── skills_collection.log      # Skills 收集日志
│   └── daily_push.log             # 推送日志
└── docs/
    └── morning_report_system.md   # 本文档
```

## 推送设置

- **频道**: Feishu
- **账号**: bot-2
- **目标**: user:ou_c051a3ac336ce444b19011d44bbd7ff1

## 报告格式示例

```markdown
📰 **早间新闻与 Skills 汇总** | 2026-03-14

---

### 🌍 全球时事（5 条）
1. **标题** - 摘要说明 [来源]
...

### 💻 科技前沿（5 条）
...

### 🤖 人工智能（5 条）
...

### 💰 金融经济（5 条）
...

---

## 📊 今日分析
[2-3 句有见解的分析]

---

🔧 **Skills 推荐**

### 热门技能
1. **技能名** - 用途说明 | 安全评分

---

_报告生成于 HH:MM_
```

## 监控与维护

### 查看日志
```bash
# 查看 Cron 执行日志
tail -f /home/admin/.openclaw/workspace/logs/cron.log

# 查看推送日志
tail -f /home/admin/.openclaw/workspace/logs/daily_push.log

# 查看新闻收集日志
tail -f /home/admin/.openclaw/workspace/logs/news_collection.log
```

### 检查 Crontab
```bash
crontab -l
```

### 手动触发推送
```bash
/home/admin/.openclaw/workspace/scripts/daily_morning_push.sh
```

## 故障排查

### 推送未执行
1. 检查 crontab 是否正常：`crontab -l`
2. 检查 cron 服务：`systemctl status cron`
3. 查看日志：`tail logs/cron.log`

### 新闻搜索失败
1. 检查网络连接
2. 检查 web_search 工具是否可用
3. 查看 sub-agent 日志

### Skills 收集失败
1. 检查 ClawHub 连接
2. 检查 agents_list 工具

## 自定义配置

### 修改推送时间
编辑 `/home/admin/.openclaw/workspace/crontab.txt`，修改对应时间后重新安装：
```bash
crontab /home/admin/.openclaw/workspace/crontab.txt
```

### 修改新闻分类
编辑 `agents/morning_report_agent.md` 中的搜索配置。

### 修改推送目标
编辑脚本中的 `TARGET_USER` 变量。

---

**最后更新**: 2026-03-14
**维护者**: OpenClaw Agent
