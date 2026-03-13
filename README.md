# OpenClaw 配置和模板文件

**用途**: 存储 OpenClaw 机器人的配置、模板和规则文档  
**适用**: 上海和新加坡服务器配置同步  
**可见性**: 私有仓库

---

## 📁 目录结构

```
github-sync/
├── templates/              # 报告模板
│   ├── A 股数据获取规则.md
│   ├── A 股报告生成规则.md
│   ├── A 股做 T 方案模板.md
│   └── A 股综合盘面分析模板.md
├── A 股数据获取规则.md     # 数据获取规则
├── 机器人学习确认.md        # 机器人学习记录
├── 机器人迁移新加坡准备清单.md  # 迁移清单
├── HEARTBEAT.md           # 心跳配置
└── .gitignore             # Git 忽略文件
```

---

## 🚀 使用方法

### 上海服务器（推送）

```bash
cd ~/.openclaw/workspace/github-sync

git add .
git commit -m "更新配置"
git push origin main
```

### 新加坡服务器（拉取）

```bash
cd ~/.openclaw/workspace/github-sync

git pull origin main
```

---

## ⚠️ 注意事项

1. **不要上传敏感信息** - API 密钥、密码、Token 等
2. **使用私有仓库** - 不要公开配置
3. **定期同步** - 保持上海和新加坡一致
4. **检查 .gitignore** - 确保敏感文件被忽略

---

## 📊 同步内容

### ✅ 可以同步
- 报告模板
- 规则文档
- 脚本文件
- 配置文件（脱敏后）

### ❌ 不能同步
- API 密钥和 Token
- 飞书机器人 API 密钥
- 个人记忆文件
- 日志文件
- 凭证文件

---

**最后更新**: 2026-03-13
