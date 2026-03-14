#!/bin/bash
# 紧急重大新闻监控脚本
# 每 30 分钟检查一次，发现重大新闻立即推送
OPENCLAW_CMD="/home/admin/.local/share/pnpm/openclaw"

set -e

WORKSPACE="/home/admin/.openclaw/workspace"
LOGS_DIR="$WORKSPACE/logs"
DATA_DIR="$WORKSPACE/data/news"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
TARGET_USER="user:ou_c051a3ac336ce444b19011d44bbd7ff1"
ACCOUNT="bot-2"

log() {
    echo "[$TIMESTAMP] $1" >> "$LOGS_DIR/breaking_news.log"
    echo "$1"
}

# 重大新闻关键词（命中即推送）
BREAKING_KEYWORDS=(
    "战争" "冲突" "军事" "导弹" "袭击"
    "地震" "台风" "洪水" "灾害" "紧急"
    "股市崩盘" "金融危机" "银行倒闭" "经济危机"
    "疫情" "病毒" "公共卫生"
    "重大政策" "国务院" "央行" "美联储"
    "AI 突破" "技术革命" "重大发布"
)

log "开始检查紧急重大新闻..."

# 创建检查任务标记文件
cat > "$DATA_DIR/breaking_news_check.json" << EOF
{
  "check_time": "$(date '+%Y-%m-%d_%H%M')",
  "keywords": ${BREAKING_KEYWORDS[@]},
  "status": "pending",
  "action": "breaking_news_monitor"
}
EOF

log "紧急新闻监控任务已创建"
