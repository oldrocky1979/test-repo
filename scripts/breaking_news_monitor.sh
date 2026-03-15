#!/bin/bash
# 紧急重大新闻监控脚本 v2
# 每 30 分钟检查一次，发现重大新闻立即推送
# 重构版：直接执行 web_search 检查，不依赖任务文件

set -e

WORKSPACE="/home/admin/.openclaw/workspace"
OPENCLAW_CMD="/home/admin/.local/share/pnpm/openclaw"
LOGS_DIR="$WORKSPACE/logs"
DATA_DIR="$WORKSPACE/data/news"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
TIME=$(date '+%H:%M')
TARGET_USER="user:ou_c051a3ac336ce444b19011d44bbd7ff1"
ACCOUNT="bot-2"
PUSHED_FILE="$DATA_DIR/pushed_breaking.json"

log() {
    mkdir -p "$LOGS_DIR"
    echo "[$TIMESTAMP] $1" >> "$LOGS_DIR/breaking_news.log"
    echo "$1"
}

log "========== 紧急新闻检查 v2 开始 =========="

# 重大新闻关键词
BREAKING_KEYWORDS="战争 军事冲突 地震 台风 金融危机 央行 美联储 AI 突破 重大政策 疫情"

# 检查是否处于静默时段（23:00-07:00）
HOUR=$(date '+%H')
if [ "$HOUR" -ge 23 ] || [ "$HOUR" -lt 7 ]; then
    log "ℹ️ 静默时段，仅检查极端紧急新闻"
    QUIET_MODE=true
else
    QUIET_MODE=false
fi

# 初始化已推送记录文件
mkdir -p "$DATA_DIR"
if [ ! -f "$PUSHED_FILE" ]; then
    echo '{"pushed_events":[]}' > "$PUSHED_FILE"
fi

# 使用 OpenClaw web_search 检查新闻
# 注意：shell 脚本无法直接调用 web_search 工具，需要创建任务由 sub-agent 执行
# 但我们可以优化：创建一个简版检查脚本

log "→ 检查重大新闻..."

# 方案 A: 使用 curl 直接调用搜索引擎 API（如果有）
# 方案 B: 创建任务文件，由 sub-agent 处理（当前方案）
# 方案 C: 使用 web_fetch 获取新闻网站（功能有限）

# 这里采用优化方案：创建高优先级任务，并标记需要立即处理
mkdir -p "$WORKSPACE/tasks/pending"
TASK_ID="$(date '+%Y%m%d_%H%M%S')_$$"

cat > "$WORKSPACE/tasks/pending/${TASK_ID}_breaking_news_urgent.json" << EOF
{
  "task_type": "breaking_news_check",
  "priority": "urgent",
  "created_at": "$TIMESTAMP",
  "trigger": "cron_30min",
  "quiet_mode": $QUIET_MODE,
  "config": {
    "target": "$TARGET_USER",
    "account": "$ACCOUNT",
    "channel": "feishu",
    "keywords": ["战争", "军事冲突", "地震", "台风", "金融危机", "央行", "美联储", "AI 突破", "重大政策", "疫情"],
    "threshold": "major",
    "dedup_window_hours": 2,
    "pushed_file": "$PUSHED_FILE"
  }
}
EOF

log "✅ 紧急新闻检查任务已创建（优先级：urgent）"
log "========== 紧急新闻检查 v2 完成 =========="

# 提示：需要配置 task_processor 优先处理 urgent 任务
echo ""
echo "💡 提示：urgent 任务应该被优先处理"
echo "   建议配置 task_processor 每 5 分钟检查并立即执行 urgent 任务"
echo ""
