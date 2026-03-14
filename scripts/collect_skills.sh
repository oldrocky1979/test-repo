#!/bin/bash
# Skills 收集脚本 - 每 4 小时运行一次
# 收集 ClawHub 和 GitHub 上的热门 Skills
OPENCLAW_CMD="/home/admin/.local/share/pnpm/openclaw"

set -e

WORKSPACE="/home/admin/.openclaw/workspace"
LOGS_DIR="$WORKSPACE/logs"
DATA_DIR="$WORKSPACE/data/skills"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
COLLECTION_TIME=$(date '+%Y-%m-%d_%H%M')

# 创建数据目录
mkdir -p "$DATA_DIR"

log() {
    echo "[$TIMESTAMP] $1" >> "$LOGS_DIR/skills_collection.log"
    echo "$1"
}

log "开始收集 Skills..."

# 创建收集任务标记
echo "$COLLECTION_TIME" > "$DATA_DIR/last_collection.txt"

# 创建临时任务文件，供后续处理
cat > "$DATA_DIR/pending_searches.json" << EOF
{
  "searches": [
    {
      "source": "clawhub",
      "query": "trending skills",
      "count": 10
    },
    {
      "source": "github",
      "query": "$OPENCLAW_CMD skills agent",
      "count": 10
    }
  ],
  "collection_time": "$COLLECTION_TIME",
  "status": "pending"
}
EOF

log "Skills 收集任务已创建，等待处理..."
log "收集时间：$COLLECTION_TIME"
