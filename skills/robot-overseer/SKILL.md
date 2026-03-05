---
name: robot-overseer
version: 1.0
description: 飞书机器人巡视管理技能。定期检查所有子代理机器人状态，生成健康报告，发现问题及时告警。
keywords: [robot, overseer, management, health-check, feishu]
---

# 机器人巡视管理机制

## 架构

```
┌─────────────────────────────────────────────────────────┐
│                    主代理 ( Overseer )                   │
│                   你是机器人总管                          │
└─────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│  feishubot    │   │  feishubot2   │   │  feishubot3   │
│  (主机器人)   │   │  (审计?)      │   │  (财务?)      │
└───────────────┘   └───────────────┘   └───────────────┘
        │                   │                   │
        ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│  feishubot4   │   │  feishubot5   │   │  feishubot6   │
│  (?)          │   │  (?)          │   │  (?)          │
└───────────────┘   └───────────────┘   └───────────────┘
```

## 巡视内容

### 1. 健康检查（每次巡视必查）

| 检查项 | 方法 | 正常标准 |
|--------|------|----------|
| Gateway 运行状态 | `openclaw gateway status` | Runtime: running |
| RPC 连接 | RPC probe | ok |
| 账号配置 | 检查 openclaw.json | 所有账号 enabled=true |
| 配对状态 | 检查 credentials | 有配对记录 |
| 内存使用 | `free -h` | 可用内存>20% |
| 磁盘空间 | `df -h` | 可用空间>10% |

### 2. 活动检查

| 检查项 | 方法 | 说明 |
|--------|------|------|
| 消息接收 | 检查日志 | 各机器人是否收到消息 |
| 消息发送 | 检查日志 | 各机器人是否成功回复 |
| 错误日志 | `openclaw logs --since 1h` | 查看错误信息 |
| 子代理状态 | `subagents action=list` | 检查活跃子代理 |

### 3. 性能检查

| 检查项 | 阈值 | 告警 |
|--------|------|------|
| 响应时间 | >5 秒 | 警告 |
| 错误率 | >5% | 警告 |
| 内存使用 | >80% | 警告 |
| CPU 使用 | >90% | 警告 |

---

## 巡视周期

| 检查类型 | 周期 | 执行时间 |
|----------|------|----------|
| 快速健康检查 | 每 30 分钟 | :00, :30 |
| 活动日志检查 | 每 2 小时 | :00 |
| 完整巡视报告 | 每天 3 次 | 9:00, 14:00, 20:00 |
| 深度诊断 | 每周 1 次 | 周一 9:00 |

---

## 巡视流程

### 快速检查流程（30 分钟）

```
1. 检查 Gateway 状态
2. 检查 RPC 连接
3. 检查内存/磁盘
4. 如有异常 → 立即告警
5. 如正常 → 记录日志
```

### 完整巡视流程（每日）

```
1. 执行快速检查
2. 检查各机器人消息日志
3. 检查子代理活动
4. 分析错误日志
5. 生成巡视报告
6. 发送报告给管理员
```

---

## 告警机制

### 告警级别

| 级别 | 条件 | 通知方式 |
|------|------|----------|
| 🔴 严重 | Gateway 宕机 | 立即通知管理员 |
| 🟠 警告 | 响应慢/错误率高 | 每小时汇总通知 |
| 🟡 注意 | 资源使用高 | 日报中体现 |
| 🟢 正常 | 一切正常 | 日报中体现 |

### 告警内容模板

```
🔴 严重告警 - [时间]

**问题：** Gateway 服务停止运行
**影响：** 所有机器人无法响应
**建议：** 立即执行 `openclaw gateway restart`

---
自动检测 | 机器人巡视系统
```

---

## 巡视报告模板

```markdown
# 机器人巡视报告

**时间：** 2026-03-05 14:00
**巡视类型：** 日常检查

## 总体状态：🟢 正常

### 机器人状态

| 机器人 | 状态 | 消息数 (24h) | 错误数 | 备注 |
|--------|------|-------------|--------|------|
| feishubot | ✅ | 150 | 0 | 正常 |
| feishubot2 | ✅ | 80 | 0 | 正常 |
| feishubot3 | ✅ | 45 | 1 | 有 1 次配对请求 |
| feishubot4 | ✅ | 0 | 0 | 未使用 |
| feishubot5 | ✅ | 0 | 0 | 未使用 |
| feishubot6 | ✅ | 0 | 0 | 未使用 |

### 系统资源

- CPU 使用：15%
- 内存使用：2.1GB / 8GB (26%)
- 磁盘使用：45GB / 100GB (45%)

### Gateway 状态

- 运行时间：2 天 5 小时
- PID: 15669
- RPC 连接：正常

### 问题与建议

无重大问题。

---
*机器人巡视系统 | 自动生成*
```

---

## 实施步骤

### 步骤 1：创建巡视脚本

```bash
#!/bin/bash
# robot-health-check.sh

# 检查 Gateway 状态
gateway_status=$(openclaw gateway status 2>&1)
if echo "$gateway_status" | grep -q "Runtime: running"; then
    echo "✅ Gateway 运行正常"
else
    echo "🔴 Gateway 异常！"
    # 发送告警
fi

# 检查内存
mem_usage=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')
if [ $mem_usage -gt 80 ]; then
    echo "🟠 内存使用率高：${mem_usage}%"
else
    echo "✅ 内存使用正常：${mem_usage}%"
fi

# 检查磁盘
disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $disk_usage -gt 90 ]; then
    echo "🔴 磁盘空间不足：${disk_usage}%"
else
    echo "✅ 磁盘使用正常：${disk_usage}%"
fi
```

### 步骤 2：配置 Cron 任务

```json
{
  "version": 1,
  "jobs": [
    {
      "id": "robot-health-quick",
      "name": "机器人快速健康检查",
      "schedule": "*/30 * * * *",
      "task": "执行快速健康检查，发现异常立即报告",
      "enabled": true
    },
    {
      "id": "robot-health-daily",
      "name": "机器人每日巡视报告",
      "schedule": "0 9,14,20 * * *",
      "task": "生成完整巡视报告并发送",
      "enabled": true
    },
    {
      "id": "robot-health-weekly",
      "name": "机器人周度深度诊断",
      "schedule": "0 9 * * 1",
      "task": "执行深度诊断，生成周报",
      "enabled": true
    }
  ]
}
```

### 步骤 3：创建状态记录文件

```markdown
# 机器人状态日志

## 2026-03-05

### 14:00 检查
- Gateway: ✅
- feishubot: ✅
- feishubot2: ✅
- feishubot3: ✅
- feishubot4: ✅
- feishubot5: ✅
- feishubot6: ✅
- 问题：无

### 09:00 检查
- 全部正常
```

---

## 子代理协作

### 分配巡视任务

```javascript
// 健康检查子代理
sessions_spawn({
  task: "执行机器人健康检查，检查 Gateway 状态、资源使用情况",
  runtime: "subagent",
  label: "health-check",
  mode: "run"
})

// 日志分析子代理
sessions_spawn({
  task: "分析过去 24 小时日志，统计各机器人消息数和错误数",
  runtime: "subagent",
  label: "log-analyzer",
  mode: "run"
})

// 报告生成子代理
sessions_spawn({
  task: "根据检查结果生成巡视报告",
  runtime: "subagent",
  label: "report-generator",
  mode: "run"
})
```

---

## 快速命令

### 手动巡视

```bash
# 快速检查
openclaw gateway status

# 查看日志
openclaw logs --since 1h

# 检查子代理
openclaw subagents list

# 查看 cron 任务
openclaw cron list
```

### 紧急处理

```bash
# 重启 Gateway
openclaw gateway restart

# 重启特定机器人（重新加载配置）
openclaw gateway reload

# 查看错误
openclaw logs --level error --since 1h
```

---

## 版本历史

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| 1.0 | 2026-03-05 | 初始版本，建立巡视机制 |
