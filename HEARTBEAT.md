# HEARTBEAT.md

## 📅 每日服务器报告推送

### 自动推送配置
- **Cron 任务**: 每天 9:00 执行 `daily_report_push.sh`
- **推送脚本**: `daily_report_auto_push.sh`
- **推送方式**: `openclaw message send --channel feishu --account bot-4`

### 推送状态文件
`/home/admin/.openclaw/workspace/logs/push_state.json`

```json
{
  "daily_report": {
    "last_pushed": "2026-03-09",
    "last_push_time": "2026-03-09T09:00:00+08:00",
    "status": "success"
  }
}
```

### ⚠️ 关键配置
- **必须使用 `--account bot-4`**，否则会出现 "open_id cross app" 错误
- **target 格式**: `user:ou_c051a3ac336ce444b19011d44bbd7ff1`

### 其他检查项
- 检查系统资源是否正常
- 检查是否有未处理的错误日志
