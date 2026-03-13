# MEMORY.md - Long-Term Memory

## Preferences

- **联网搜索优先使用 searxng skill** —— 只要涉及联网搜索任务，优先调用 searxng 技能而非直接使用 web_search 工具。
- **每日报告设置**：每天早上 9 点自动生成服务器运行情况报告，包括磁盘、内存、CPU 使用情况

## Notes

- Created: 2026-03-05
- **浏览器搜索问题已解决**：优先使用百度搜索，避免 GitHub 等国外服务不稳定问题
- **elite-longterm-memory 部署风险**：已有两次崩溃历史，建议使用 OpenClaw 原生内存系统
- **每日报告功能**：已设置 cron 任务，每天 9 点自动运行 `/home/admin/.openclaw/workspace/scripts/daily_report.sh`
