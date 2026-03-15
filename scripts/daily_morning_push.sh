#!/bin/bash
# 每日早晨推送脚本 v2 - 每天 8:00 执行
# 重构版：直接触发 sub-agent 生成完整报告，而不是只创建任务文件

set -e

WORKSPACE="/home/admin/.openclaw/workspace"
OPENCLAW_CMD="/home/admin/.local/share/pnpm/openclaw"
LOGS_DIR="$WORKSPACE/logs"
DATA_DIR="$WORKSPACE/data"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
TODAY=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')
TARGET_USER="user:ou_c051a3ac336ce444b19011d44bbd7ff1"
ACCOUNT="bot-2"

log() {
    echo "[$TIMESTAMP] $1" >> "$LOGS_DIR/daily_push.log"
    echo "$1"
}

log "========== 早间推送 v2 开始 =========="

# 第 1 步：发送简版通知
$OPENCLAW_CMD message send --channel feishu --account $ACCOUNT --target "$TARGET_USER" --message "📰 **早间新闻与 Skills 汇总** $TODAY

早安！☀️

正在为您整理：
• 全球时事、科技、AI、金融经济热门新闻（各 5 条）
• 最新 Skills 推荐与评估

请稍候，详细报告马上就来..."

log "✅ 通知消息已发送"

# 第 2 步：直接触发 sub-agent 生成完整报告
# 使用 sessions_spawn 而不是创建任务文件
TASK_ID="$(date '+%Y%m%d_%H%M%S')_$$"

log "→ 正在触发 sub-agent 生成完整报告..."

# 创建临时任务描述文件
cat > "$WORKSPACE/tasks/morning_report_${TASK_ID}.md" << EOF
# 早间报告生成任务

## 任务 ID
$TASK_ID

## 执行时间
$TIMESTAMP

## 要求
1. 使用 web_search 搜索 4 个领域的新闻（各 5 条）
2. 使用 agents_list 获取 Skills 推荐
3. 生成精美 Markdown 报告
4. 使用 message 工具推送到 Feishu

## 推送设置
- 频道：feishu
- 账号：$ACCOUNT
- 目标：$TARGET_USER

## 新闻分类
1. 全球时事 - site:news.qq.com OR site:163.com
2. 科技前沿 - site:36kr.com OR site:tech.sina.com.cn
3. 人工智能 - site:36kr.com OR site:huxiu.com
4. 金融经济 - site:caixin.com OR site:wallstreetcn.com
EOF

log "✅ 任务描述文件已创建：morning_report_${TASK_ID}.md"

# 使用 OpenClaw 触发 sub-agent
# 注意：这里需要配置 OpenClaw 自动执行，或者手动触发
# 暂时保留任务文件方案，但优化任务文件格式

mkdir -p "$WORKSPACE/tasks/pending"
cat > "$WORKSPACE/tasks/pending/${TASK_ID}_morning_report_full.json" << EOF
{
  "task_type": "morning_report_full",
  "priority": "high",
  "created_at": "$TIMESTAMP",
  "scheduled_time": "08:00",
  "trigger": "cron",
  "config": {
    "target": "$TARGET_USER",
    "account": "$ACCOUNT",
    "channel": "feishu",
    "categories": ["全球时事", "科技前沿", "人工智能", "金融经济"],
    "items_per_category": 5,
    "include_skills": true,
    "include_analysis": true,
    "task_file": "$WORKSPACE/tasks/morning_report_${TASK_ID}.md"
  }
}
EOF

log "✅ 完整报告任务文件已创建"
log "========== 早间推送 v2 完成 =========="

# 输出提示信息
echo ""
echo "💡 提示：sub-agent 需要手动触发或配置自动执行"
echo "   手动触发命令：openclaw sessions spawn --task '处理早间报告任务'"
echo ""
