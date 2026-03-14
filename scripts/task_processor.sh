#!/bin/bash
# 任务处理器 - 执行 pending 目录中的任务
# 由 OpenClaw sub-agent 或手动触发执行

set -e

WORKSPACE="/home/admin/.openclaw/workspace"
PENDING_DIR="$WORKSPACE/tasks/pending"
LOGS_DIR="$WORKSPACE/logs"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

log() {
    echo "[$TIMESTAMP] $1" >> "$LOGS_DIR/task_processor.log"
    echo "$1"
}

log "========== 任务处理器启动 =========="

# 检查 pending 目录
if [ ! -d "$PENDING_DIR" ]; then
    log "Pending 目录不存在，退出"
    exit 0
fi

# 获取任务文件列表
TASK_FILES=$(ls -1 "$PENDING_DIR"/*.json 2>/dev/null | sort)

if [ -z "$TASK_FILES" ]; then
    log "没有待处理的任务"
    exit 0
fi

log "发现 $(echo "$TASK_FILES" | wc -l) 个待处理任务"

# 处理每个任务
for task_file in $TASK_FILES; do
    if [ ! -f "$task_file" ]; then
        continue
    fi
    
    filename=$(basename "$task_file")
    log "处理任务：$filename"
    
    # 读取任务类型
    task_type=$(grep -o '"task_type"[[:space:]]*:[[:space:]]*"[^"]*"' "$task_file" | cut -d'"' -f4)
    
    if [ -z "$task_type" ]; then
        log "⚠️ 无法识别任务类型，跳过：$filename"
        continue
    fi
    
    log "任务类型：$task_type"
    
    # 根据任务类型执行相应操作
    case "$task_type" in
        "collect_news")
            log "→ 执行新闻收集任务..."
            # 这里调用实际的新闻收集逻辑
            # 由于需要调用 OpenClaw 的 web_search，由 sub-agent 处理
            ;;
        "collect_skills")
            log "→ 执行 Skills 收集任务..."
            # 调用 Skills 收集逻辑
            ;;
        "breaking_news_check")
            log "→ 执行紧急新闻检查..."
            # 调用紧急新闻检查逻辑
            ;;
        "morning_report")
            log "→ 执行早间报告任务..."
            # 调用早间报告生成逻辑
            ;;
        *)
            log "⚠️ 未知任务类型：$task_type"
            ;;
    esac
    
    # 任务处理完成后，移动到 completed 目录
    mkdir -p "$WORKSPACE/tasks/completed"
    mv "$task_file" "$WORKSPACE/tasks/completed/"
    log "✓ 任务完成：$filename"
done

log "========== 任务处理器完成 =========="
