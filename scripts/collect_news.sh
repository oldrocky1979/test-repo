#!/bin/bash
# 新闻收集脚本 - 每 4 小时运行一次
# 收集全球时事、科技、AI、金融经济四个领域的热门新闻
OPENCLAW_CMD="/home/admin/.local/share/pnpm/openclaw"

set -e

WORKSPACE="/home/admin/.openclaw/workspace"
LOGS_DIR="$WORKSPACE/logs"
DATA_DIR="$WORKSPACE/data/news"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
COLLECTION_TIME=$(date '+%Y-%m-%d_%H%M')

# 创建数据目录
mkdir -p "$DATA_DIR"

log() {
    echo "[$TIMESTAMP] $1" >> "$LOGS_DIR/news_collection.log"
    echo "$1"
}

log "开始收集新闻..."

# 使用 OpenClaw 的 web_search 收集新闻
# 由于 shell 无法直接调用 OpenClaw 工具，我们创建一个标记文件
# 实际的搜索由后续的 sub-agent 或定时任务完成

# 创建收集任务标记
echo "$COLLECTION_TIME" > "$DATA_DIR/last_collection.txt"

# 创建临时任务文件，供后续处理
cat > "$DATA_DIR/pending_searches.json" << EOF
{
  "collections": [
    {
      "category": "全球时事",
      "queries": ["国际新闻 今日热点", "world news breaking today", "全球重大事件 2026"],
      "count": 5
    },
    {
      "category": "科技新闻", 
      "queries": ["科技新闻 今日", "tech news today 2026", "科技创新 最新发布"],
      "count": 5
    },
    {
      "category": "人工智能",
      "queries": ["AI 人工智能 最新进展", "artificial intelligence news today", "大模型 新突破"],
      "count": 5
    },
    {
      "category": "金融经济",
      "queries": ["金融市场 今日动态", "financial news economy today", "股市 汇市 最新"],
      "count": 5
    }
  ],
  "collection_time": "$COLLECTION_TIME",
  "status": "pending"
}
EOF

log "新闻收集任务已创建，等待处理..."
log "收集时间：$COLLECTION_TIME"
