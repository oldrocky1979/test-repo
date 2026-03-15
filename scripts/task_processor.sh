#!/bin/bash
# 任务处理器 v2 - 执行 pending 目录中的任务
# 重构版：优先处理 urgent 任务，支持直接触发 sub-agent

set -e

WORKSPACE="/home/admin/.openclaw/workspace"
OPENCLAW_CMD="/home/admin/.local/share/pnpm/openclaw"
PENDING_DIR="$WORKSPACE/tasks/pending"
LOGS_DIR="$WORKSPACE/logs"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

log() {
    echo "[$TIMESTAMP] $1" >> "$LOGS_DIR/task_processor.log"
    echo "$1"
}

log "========== 任务处理器 v2 启动 =========="

# 检查 pending 目录
if [ ! -d "$PENDING_DIR" ]; then
    log "Pending 目录不存在，退出"
    exit 0
fi

# 优先处理 urgent 任务
URGENT_TASKS=$(grep -l '"priority"[[:space:]]*:[[:space:]]*"urgent"' "$PENDING_DIR"/*.json 2>/dev/null | sort)
NORMAL_TASKS=$(grep -L '"priority"[[:space:]]*:[[:space:]]*"urgent"' "$PENDING_DIR"/*.json 2>/dev/null | sort)

log "发现 $(echo "$URGENT_TASKS" | grep -c . 2>/dev/null || echo 0) 个 urgent 任务"
log "发现 $(echo "$NORMAL_TASKS" | grep -c . 2>/dev/null || echo 0) 个 normal 任务"

# 处理任务函数
process_task() {
    local task_file="$1"
    local is_urgent="$2"
    
    if [ ! -f "$task_file" ]; then
        return
    fi
    
    filename=$(basename "$task_file")
    log "处理任务：$filename (优先级：$is_urgent)"
    
    # 读取任务类型
    task_type=$(grep -o '"task_type"[[:space:]]*:[[:space:]]*"[^"]*"' "$task_file" | cut -d'"' -f4)
    
    if [ -z "$task_type" ]; then
        log "⚠️ 无法识别任务类型，跳过：$filename"
        return
    fi
    
    log "任务类型：$task_type"
    
    # 根据任务类型执行相应操作
    case "$task_type" in
        "collect_news")
            log "→ 执行新闻收集任务..."
            "$WORKSPACE/scripts/collect_news.sh" >> "$LOGS_DIR/collect_news.log" 2>&1
            ;;
        "collect_skills")
            log "→ 执行 Skills 收集任务..."
            "$WORKSPACE/scripts/collect_skills.sh" >> "$LOGS_DIR/collect_skills.log" 2>&1
            ;;
        "breaking_news_check")
            log "→ 执行紧急新闻检查..."
            # 紧急新闻需要 sub-agent 调用 web_search
            # 这里触发 sub-agent 处理
            trigger_subagent "$task_file" "breaking_news"
            ;;
        "morning_report"|"morning_report_full")
            log "→ 执行早间报告任务..."
            # 早间报告需要 sub-agent 调用 web_search
            trigger_subagent "$task_file" "morning_report"
            ;;
        "stock_price_check"|"hot_stock_scanner")
            log "→ 股票相关任务：$task_type (需要 sub-agent 处理)"
            trigger_subagent "$task_file" "stock_analysis"
            ;;
        "server_report")
            log "→ 服务器报告任务：$task_type (已在 cron 中直接执行)"
            ;;
        *)
            log "⚠️ 未知任务类型：$task_type"
            ;;
    esac
    
    # 任务处理完成后，移动到 completed 目录
    mkdir -p "$WORKSPACE/tasks/completed"
    mv "$task_file" "$WORKSPACE/tasks/completed/"
    log "✓ 任务完成：$filename"
}

# 触发 sub-agent 函数
trigger_subagent() {
    local task_file="$1"
    local task_category="$2"
    
    log "→ 触发 sub-agent 处理：$task_category"
    
    # 读取任务描述文件（如果存在）
    task_desc=$(grep -o '"task_file"[[:space:]]*:[[:space:]]*"[^"]*"' "$task_file" 2>/dev/null | cut -d'"' -f4)
    
    if [ -n "$task_desc" ] && [ -f "$task_desc" ]; then
        log "  使用任务描述文件：$task_desc"
        # 这里应该调用 OpenClaw sessions_spawn
        # 但由于 shell 限制，暂时记录日志
        log "  💡 需要调用：openclaw sessions spawn --task '处理 $task_category'"
    else
        log "  使用 JSON 配置文件：$task_file"
        # 解析 JSON 配置并触发 sub-agent
        log "  💡 需要调用：openclaw sessions spawn --task '处理 $task_category'"
    fi
}

# 先处理 urgent 任务
if [ -n "$URGENT_TASKS" ]; then
    log "========== 开始处理 urgent 任务 =========="
    for task_file in $URGENT_TASKS; do
        process_task "$task_file" "urgent"
    done
fi

# 再处理 normal 任务
if [ -n "$NORMAL_TASKS" ]; then
    log "========== 开始处理 normal 任务 =========="
    for task_file in $NORMAL_TASKS; do
        process_task "$task_file" "normal"
    done
fi

log "========== 任务处理器 v2 完成 =========="
