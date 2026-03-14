#!/bin/bash
# OpenClaw 定时任务统一调度脚本 v2
# 通过创建任务文件 + OpenClaw CLI 触发 sub-agent 执行
OPENCLAW_CMD="/home/admin/.local/share/pnpm/openclaw"

set -e

WORKSPACE="/home/admin/.openclaw/workspace"
LOGS_DIR="$WORKSPACE/logs"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
TASK_ID="$(date '+%Y%m%d_%H%M%S')_$$"

log() {
    mkdir -p "$LOGS_DIR"
    echo "[$TIMESTAMP] $1" >> "$LOGS_DIR/task_scheduler.log"
    echo "$1"
}

TASK="$1"
DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')

log "========== 任务调度开始 =========="
log "任务：$TASK"
log "时间：$DATE $TIME"
log "任务 ID: $TASK_ID"

# 创建任务文件
mkdir -p "$WORKSPACE/tasks/pending"

case "$TASK" in
    "morning_report")
        cat > "$WORKSPACE/tasks/pending/${TASK_ID}_morning_report.json" << EOF
{
  "task_type": "morning_report",
  "created_at": "$TIMESTAMP",
  "scheduled_time": "08:00",
  "config": {
    "target": "user:ou_c051a3ac336ce444b19011d44bbd7ff1",
    "account": "bot-2",
    "channel": "feishu",
    "categories": ["全球时事", "科技前沿", "人工智能", "金融经济"],
    "items_per_category": 5,
    "include_skills": true,
    "include_analysis": true
  }
}
EOF
        log "✓ 早间报告任务文件已创建"
        ;;
    
    "breaking_news_check")
        cat > "$WORKSPACE/tasks/pending/${TASK_ID}_breaking_news.json" << EOF
{
  "task_type": "breaking_news_check",
  "created_at": "$TIMESTAMP",
  "config": {
    "target": "user:ou_c051a3ac336ce444b19011d44bbd7ff1",
    "account": "bot-2",
    "channel": "feishu",
    "keywords": ["战争", "军事", "冲突", "地震", "台风", "金融危机", "央行", "美联储", "AI 突破", "重大政策", "疫情"],
    "quiet_hours": false
  }
}
EOF
        log "✓ 紧急新闻检查任务文件已创建"
        ;;
    
    "collect_news")
        cat > "$WORKSPACE/tasks/pending/${TASK_ID}_collect_news.json" << EOF
{
  "task_type": "collect_news",
  "created_at": "$TIMESTAMP",
  "config": {
    "categories": ["全球时事", "科技前沿", "人工智能", "金融经济"],
    "items_per_category": 10,
    "output_dir": "$WORKSPACE/data/news/cache"
  }
}
EOF
        log "✓ 新闻收集任务文件已创建"
        ;;
    
    "collect_skills")
        cat > "$WORKSPACE/tasks/pending/${TASK_ID}_collect_skills.json" << EOF
{
  "task_type": "collect_skills",
  "created_at": "$TIMESTAMP",
  "config": {
    "sources": ["clawhub", "github"],
    "output_dir": "$WORKSPACE/data/skills/cache"
  }
}
EOF
        log "✓ Skills 收集任务文件已创建"
        ;;
    
    "server_1205am")
        log "调用服务器报告脚本..."
        "$WORKSPACE/scripts/scheduled_tasks.sh" "server_1205am" 2>&1 | tee -a "$LOGS_DIR/server_report.log"
        ;;
    
    "forex_stock_9am"|"stock_12pm"|"forex_3pm"|"stock_340pm"|"forex_8pm")
        log "调用金融分析脚本：$TASK"
        "$WORKSPACE/scripts/scheduled_tasks.sh" "$TASK" 2>&1 | tee -a "$LOGS_DIR/forex_stock.log"
        ;;
    
    *)
        log "✗ 未知任务：$TASK"
        echo "可用任务：morning_report, breaking_news_check, collect_news, collect_skills, server_1205am, forex_stock_9am, stock_12pm, forex_3pm, stock_340pm, forex_8pm"
        exit 1
        ;;
esac

log "========== 任务调度完成 =========="
