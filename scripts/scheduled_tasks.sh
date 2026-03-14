#!/bin/bash
# 定时任务调度脚本
# 工作日定时推送任务
OPENCLAW_CMD="/home/admin/.local/share/pnpm/openclaw"

set -e

WORKSPACE="/home/admin/.openclaw/workspace"
LOGS_DIR="$WORKSPACE/logs"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
TARGET_USER="user:ou_c051a3ac336ce444b19011d44bbd7ff1"
ACCOUNT="bot-2"

log() {
    echo "[$TIMESTAMP] $1" >> "$LOGS_DIR/scheduled_tasks.log"
}

# 检查是否是工作日 (1-5 为周一到周五)
DAY_OF_WEEK=$(date +%u)
IS_WEEKEND=0
if [ "$DAY_OF_WEEK" -gt 5 ]; then
    IS_WEEKEND=1
fi

TASK="$1"

case "$TASK" in
    "server_1205am")
        log "执行 0:05 服务器报告和 Tokens 使用情况推送"
        $OPENCLAW_CMD message send --channel feishu --account $ACCOUNT --target "$TARGET_USER" --message "🖥️ **服务器日报** $(date '+%Y-%m-%d')

📊 服务器运行情况
💰 Tokens 使用量 & 价格统计

正在生成详细报告..."
        ;;
    
    "news_8am")
        log "执行 8:00 Google News 热门新闻推送"
        $OPENCLAW_CMD message send --channel feishu --account $ACCOUNT --target "$TARGET_USER" --message "📰 **早间新闻速递** $(date '+%Y-%m-%d %H:%M')

早安！正在为您获取今日 Google News 热门新闻..."
        ;;
    
    "skills_8am")
        log "执行 8:00 Skills 汇总推送"
        $OPENCLAW_CMD message send --channel feishu --account $ACCOUNT --target "$TARGET_USER" --message "🔧 **Skills 每日汇总** $(date '+%Y-%m-%d %H:%M')

正在整理昨日热门 Skills 和评估报告..."
        ;;
    
    "forex_stock_9am"|"stock_12pm"|"forex_3pm"|"stock_340pm"|"forex_8pm")
        # 工作日任务，周末跳过
        if [ "$IS_WEEKEND" -eq 1 ]; then
            log "周末，跳过工作日任务：$TASK"
            exit 0
        fi
        case "$TASK" in
            "forex_stock_9am")
                log "执行 9:00 外汇和 A 股分析推送"
                $OPENCLAW_CMD message send --channel feishu --account $ACCOUNT --target "$TARGET_USER" --message "💱 **早盘分析** $(date '+%Y-%m-%d %H:%M')

📊 外汇市场分析
📈 A 股市场展望

正在生成详细分析报告..."
                ;;
            "stock_12pm")
                log "执行 12:00 A 股早盘回顾"
                $OPENCLAW_CMD message send --channel feishu --account $ACCOUNT --target "$TARGET_USER" --message "📊 **A 股早盘回顾** $(date '+%Y-%m-%d %H:%M')

市场已过半，正在分析上午盘面情况..."
                ;;
            "forex_3pm")
                log "执行 15:00 外汇欧洲盘分析"
                $OPENCLAW_CMD message send --channel feishu --account $ACCOUNT --target "$TARGET_USER" --message "💱 **外汇欧洲盘前瞻** $(date '+%Y-%m-%d %H:%M')

欧洲盘即将开盘，正在准备分析报告..."
                ;;
            "stock_340pm")
                log "执行 15:40 A 股收盘分析"
                $OPENCLAW_CMD message send --channel feishu --account $ACCOUNT --target "$TARGET_USER" --message "📊 **A 股收盘分析** $(date '+%Y-%m-%d %H:%M')

市场已收盘，正在生成复盘报告..."
                ;;
            "forex_8pm")
                log "执行 20:00 美洲盘分析"
                $OPENCLAW_CMD message send --channel feishu --account $ACCOUNT --target "$TARGET_USER" --message "💱 **外汇美洲盘前瞻** $(date '+%Y-%m-%d %H:%M')

美洲盘即将开盘，正在准备分析报告..."
                ;;
        esac
        ;;
    
    *)
        log "未知任务：$TASK"
        echo "Usage: $0 {server_1205am|news_8am|skills_8am|forex_stock_9am|stock_12pm|forex_3pm|stock_340pm|forex_8pm}"
        exit 1
        ;;
esac

log "任务 $TASK 执行完成"
