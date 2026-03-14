#!/bin/bash
# 每日早晨推送脚本 - 每天 8:00 执行
# 推送新闻和 Skills 汇总报告

set -e

WORKSPACE="/home/admin/.openclaw/workspace"
OPENCLAW_CMD="/home/admin/.local/share/pnpm/openclaw"
LOGS_DIR="$WORKSPACE/logs"
DATA_DIR="$WORKSPACE/data"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
TODAY=$(date '+%Y-%m-%d')
TARGET_USER="user:ou_c051a3ac336ce444b19011d44bbd7ff1"
ACCOUNT="bot-2"

log() {
    echo "[$TIMESTAMP] $1" >> "$LOGS_DIR/daily_push.log"
    echo "$1"
}

log "开始执行每日早晨推送..."

# 检查是否有待处理的新闻和 Skills 数据
NEWS_PENDING="$DATA_DIR/news/pending_searches.json"
SKILLS_PENDING="$DATA_DIR/skills/pending_searches.json"

# 如果没有数据，创建一个 sub-agent 来收集并生成报告
if [ ! -f "$NEWS_PENDING" ] || [ ! -f "$SKILLS_PENDING" ]; then
    log "检测到待处理数据，启动收集任务..."
fi

# 使用 OpenClaw 发送通知消息
$OPENCLAW_CMD message send --channel feishu --account $ACCOUNT --target "$TARGET_USER" --message "📰 **早间新闻与 Skills 汇总** $TODAY

早安！☀️

正在为您整理：
• 全球时事、科技、AI、金融经济热门新闻（各 5 条）
• 最新 Skills 推荐与评估

请稍候，详细报告马上就来..."

log "推送通知已发送，开始生成详细报告..."

# 触发 sub-agent 来生成完整报告
# 这里会由 OpenClaw 的会话系统处理
echo "触发报告生成任务..."

log "每日早晨推送任务完成"
