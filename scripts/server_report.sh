#!/bin/bash
# 服务器日报 + Tokens 使用情况统计脚本
# 每天 00:05 执行

set -e

WORKSPACE="/home/admin/.openclaw/workspace"
LOGS_DIR="$WORKSPACE/logs"
DATA_DIR="$WORKSPACE/data"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
TODAY=$(date '+%Y-%m-%d')
YESTERDAY=$(date -d "yesterday" '+%Y-%m-%d' 2>/dev/null || date -v-1d '+%Y-%m-%d' 2>/dev/null || date '+%Y-%m-%d')
TARGET_USER="user:ou_c051a3ac336ce444b19011d44bbd7ff1"
ACCOUNT="bot-2"

log() {
    mkdir -p "$LOGS_DIR"
    echo "[$TIMESTAMP] $1" >> "$LOGS_DIR/server_report.log"
    echo "$1"
}

log "========== 服务器报告开始 =========="

# 创建任务文件，由 sub-agent 执行详细统计
mkdir -p "$DATA_DIR/tasks"
cat > "$DATA_DIR/tasks/server_report_${TODAY}.json" << EOF
{
  "task_type": "server_report",
  "created_at": "$TIMESTAMP",
  "report_date": "$TODAY",
  "config": {
    "target": "$TARGET_USER",
    "account": "$ACCOUNT",
    "channel": "feishu",
    "include_tokens": true,
    "include_cost": true,
    "include_servers": ["local", "singapore"],
    "token_stats": {
      "models": ["qwen3.5-plus", "qwen3-max", "gpt-4", "claude-3"],
      "metrics": ["input_tokens", "output_tokens", "total_tokens", "cost_usd", "cost_cny"]
    }
  }
}
EOF

log "服务器报告任务文件已创建"
log "========== 服务器报告完成 =========="
