#!/bin/bash
# Skills 收集脚本 v2 - 每 4 小时运行一次
# 从 Twitter、GitHub、ClawHub 收集 Skills 信息
# ⚠️ 仅收集信息，不安装！

set -e

WORKSPACE="/home/admin/.openclaw/workspace"
LOGS_DIR="$WORKSPACE/logs"
DATA_DIR="$WORKSPACE/data/skills"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
COLLECTION_TIME=$(date '+%Y-%m-%d_%H%M')

# 创建数据目录
mkdir -p "$DATA_DIR/discovered"
mkdir -p "$DATA_DIR/evaluated"
mkdir -p "$DATA_DIR/pending"

log() {
    echo "[$TIMESTAMP] $1" >> "$LOGS_DIR/skills_collection.log"
    echo "$1"
}

log "========== Skills 收集 v2 开始 =========="
log "收集时间：$COLLECTION_TIME"
log "⚠️ 规则：仅收集信息，不安装！"

# 创建发现任务文件
cat > "$DATA_DIR/discovered/${COLLECTION_TIME}_search_plan.json" << EOF
{
  "collection_time": "$COLLECTION_TIME",
  "status": "pending",
  "sources": [
    {
      "name": "Twitter/X",
      "priority": "high",
      "searches": [
        {
          "query": "\"openclaw skill\" filter:links",
          "time_range": "week",
          "count": 10
        },
        {
          "query": "\"clawdbot extension\" filter:links",
          "time_range": "week",
          "count": 10
        },
        {
          "query": "\"ai agent tool\" github filter:links",
          "time_range": "week",
          "count": 10
        }
      ],
      "output": "$DATA_DIR/discovered/twitter_results.json"
    },
    {
      "name": "GitHub",
      "priority": "high",
      "searches": [
        {
          "query": "openclaw skill agent",
          "sort": "stars",
          "count": 15
        },
        {
          "query": "clawdbot skill extension",
          "sort": "updated",
          "count": 10
        },
        {
          "query": "openclaw plugin automation",
          "sort": "stars",
          "count": 10
        }
      ],
      "output": "$DATA_DIR/discovered/github_results.json"
    },
    {
      "name": "ClawHub",
      "priority": "medium",
      "searches": [
        {
          "query": "trending skills",
          "url": "https://clawhub.com",
          "count": 10
        }
      ],
      "output": "$DATA_DIR/discovered/clawhub_results.json"
    }
  ],
  "next_step": "evaluate",
  "note": "⚠️ 收集完成后进入评估流程，不直接安装！"
}
EOF

log "✅ 发现任务已创建"
log "📂 输出目录：$DATA_DIR/discovered/"
log ""
log "下一步："
log "1. 执行搜索，收集技能信息"
log "2. 对每个技能进行评估（evaluate_skill.sh）"
log "3. 生成评估报告"
log "4. 用户决定是否安装"
log ""
log "⚠️ 重要：所有 skill 必须先评估，后安装！"
log "========== Skills 收集 v2 完成 =========="
