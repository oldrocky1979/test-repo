# Skill 安全扫描机制 v1.0

**创建日期**: 2026-03-15  
**核心原则**: **安装前必须扫描，扫描通过才能安装！**

---

## 🚨 为什么需要安全扫描？

根据 awesome-openclaw-skills 的数据：

| 过滤类型 | 排除数量 |
|----------|----------|
| 可能垃圾（批量账号、机器人） | 4,065 |
| 重复/相似名称 | 1,040 |
| 低质量或非英文描述 | 851 |
| 加密货币/区块链/金融 | 731 |
| **恶意代码（安全审计发现）** | **373** |
| **总计排除** | **7,060** |

> OpenClaw's public registry hosts 13,729 skills. This awesome list has 5,366 skills after filtering.

**⚠️ 373 个恶意技能已被安全审计发现并排除！**

---

## 🛡️ 三层安全扫描体系

```
┌─────────────────────────────────────────────────────────────┐
│  第 1 层：VirusTotal 自动扫描（ClawHub 集成）                 │
├─────────────────────────────────────────────────────────────┤
│  ✅ 官方合作，自动扫描                                        │
│  ✅ 每 skill 生成 VirusTotal 报告                              │
│  ✅ 在 ClawHub 页面查看                                        │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  第 2 层：Snyk Agent Scan（专业扫描）                        │
├─────────────────────────────────────────────────────────────┤
│  ✅ 检测 15+ 种安全风险                                        │
│  ✅ 扫描 prompt injections、malware payloads                 │
│  ✅ 检测 credential handling、hardcoded secrets             │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  第 3 层：本地安全审计（security-audit.sh）                  │
├─────────────────────────────────────────────────────────────┤
│  ✅ 检查文件权限                                              │
│  ✅ 扫描暴露的 secrets                                        │
│  ✅ 检查 gateway 配置                                         │
│  ✅ 验证 injection defense rules                            │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔍 第 1 层：VirusTotal 自动扫描

### 官方合作

OpenClaw 与 VirusTotal 有官方合作，为 ClawHub 上的技能提供自动安全扫描。

### 查看方法

1. 访问技能页面：`https://clawhub.ai/<skill-slug>`
2. 查找 **VirusTotal Report** 部分
3. 查看是否有 flagged as risky

### 示例

```
https://clawhub.ai/steipete/slack
→ 查看 VirusTotal 报告
→ 确认无风险标记
```

### 限制

- ✅ 仅适用于 ClawHub 上的技能
- ✅ 自动扫描，无需手动操作
- ⚠️ 个人 GitHub 仓库的技能无此保护

---

## 🔍 第 2 层：Snyk Agent Scan（推荐）⭐

### 什么是 Snyk Agent Scan？

Snyk 推出的专业 AI 代理安全扫描工具，可检测 15+ 种安全风险。

**GitHub**: https://github.com/snyk/agent-scan

### 检测的风险类型

#### MCP 服务器风险
| 代码 | 风险类型 | 说明 |
|------|----------|------|
| E001 | Prompt Injection | 恶意注入指令 |
| E002 | Tool Shadowing | 工具覆盖攻击 |
| E003 | Tool Poisoning | 工具功能投毒 |
| TF001 | Toxic Flows | 有毒数据流 |

#### Agent Skills 风险
| 代码 | 风险类型 | 说明 |
|------|----------|------|
| E004 | Prompt Injection | SKILL.md 中的注入 |
| E006 | Malware Payloads | 隐藏恶意代码 |
| W011 | Untrusted Content | 不可信内容处理 |
| W007 | Credential Handling | 凭证处理风险 |
| W008 | Hardcoded Secrets | 硬编码密钥 |

### 安装方法

```bash
# 1. 注册 Snyk 账号
访问：https://snyk.io

# 2. 获取 API Token
访问：https://app.snyk.io/account
点击 API Token → KEY → 显示

# 3. 设置环境变量
export SNYK_TOKEN=your-api-token-here

# 4. 安装 uv（如果未安装）
curl -LsSf https://astral.sh/uv/install.sh | sh

# 5. 运行扫描
uvx snyk-agent-scan@latest
```

### 扫描单个 Skill

```bash
# 扫描 SKILL.md 文件
uvx snyk-agent-scan@latest /path/to/skill/SKILL.md

# 扫描整个技能目录
uvx snyk-agent-scan@latest ~/.openclaw/skills/skill-name/

# 扫描所有 Claude 技能
uvx snyk-agent-scan@latest ~/.claude/skills
```

### 扫描输出示例

```
🔍 Scanning: /path/to/skill/SKILL.md

❌ E004 - Prompt Injection detected
   Location: SKILL.md, line 45
   Pattern: "Ignore previous instructions"
   Severity: HIGH

⚠️  W008 - Possible hardcoded secret
   Location: scripts/run.sh, line 12
   Pattern: API key detected
   Severity: MEDIUM

✅ Scan complete: 1 issue, 1 warning
```

### 集成到安装流程

```bash
#!/bin/bash
# install_skill_with_scan.sh

SKILL_PATH="$1"

echo "🔍 开始安全扫描..."

# 运行 Snyk 扫描
SCAN_RESULT=$(uvx snyk-agent-scan@latest "$SKILL_PATH" 2>&1)

# 检查扫描结果
if echo "$SCAN_RESULT" | grep -q "❌.*E00[1-6]"; then
    echo "❌ 扫描失败：发现严重安全问题"
    echo "$SCAN_RESULT"
    exit 1
fi

if echo "$SCAN_RESULT" | grep -q "⚠️"; then
    echo "⚠️  扫描警告：发现潜在风险"
    echo "$SCAN_RESULT"
    echo ""
    read -p "是否继续安装？(y/N): " confirm
    if [ "$confirm" != "y" ]; then
        echo "❌ 安装已取消"
        exit 1
    fi
fi

echo "✅ 扫描通过，继续安装..."
# 继续安装流程...
```

---

## 🔍 第 3 层：本地安全审计

### 使用现有脚本

我们已经有 `proactive-agent/security-audit.sh`！

**位置**: `/home/admin/.openclaw/workspace/skills/proactive-agent/scripts/security-audit.sh`

### 运行方法

```bash
cd /home/admin/.openclaw/workspace
./skills/proactive-agent/scripts/security-audit.sh
```

### 检查项目

1. ✅ **凭证文件权限** - 检查 `.credentials/` 目录权限是否为 600
2. ✅ **暴露的 secrets** - 扫描常见文件中的 API key、password、token
3. ✅ **Gateway 配置** - 检查是否绑定到 loopback
4. ✅ **Injection Defense** - 验证 AGENTS.md 是否包含防护规则
5. ✅ **技能来源审查** - 检查已安装技能的可信度
6. ✅ **.gitignore** - 确认敏感文件已被忽略

### 输出示例

```
🔒 Proactive Agent Security Audit
==================================

📁 Checking credential files...
✅ .credentials/api_key permissions OK (600)

🔍 Scanning for exposed secrets...
⚠️  WARNING: Possible secret in config.json - review manually
✅ Secret scan complete

🌐 Checking gateway configuration...
✅ Gateway bound to loopback (not exposed)

📋 Checking AGENTS.md for security rules...
✅ AGENTS.md contains injection defense rules
✅ AGENTS.md contains deletion confirmation rules

📦 Checking installed skills...
   Found 15 installed skills
✅ Review skills manually for trustworthiness

📄 Checking .gitignore...
✅ .credentials is gitignored
✅ .env files are gitignored

==================================
📊 Summary
==================================
1 warning(s), 0 issues
```

---

## 📋 完整安全扫描流程

### 安装前流程（必须遵守）

```
┌─────────────────────────────────────────────────────────────┐
│  发现技能（GitHub/ClawHub/Twitter）                          │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  第 1 步：VirusTotal 检查（ClawHub 技能）                       │
│  - 访问 clawhub.ai/<skill>                                  │
│  - 查看 VirusTotal 报告                                       │
│  - ❌ 有风险 → 终止                                          │
│  - ✅ 无风险 → 继续                                          │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  第 2 步：Snyk Agent Scan                                    │
│  - uvx snyk-agent-scan@latest <skill-path>                  │
│  - ❌ E001-E006 → 终止                                       │
│  - ⚠️  W 级别警告 → 人工审查                                 │
│  - ✅ 无问题 → 继续                                          │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  第 3 步：人工代码审查                                        │
│  - 阅读 SKILL.md                                             │
│  - 检查 scripts/ 目录                                         │
│  - 查看权限需求                                              │
│  - 确认无危险操作                                            │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  第 4 步：生成评估报告                                        │
│  - 4 维度评分（实用性/安全性/完整性/活跃度）                   │
│  - 包含安全扫描结果                                          │
│  - 用户确认                                                  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  第 5 步：用户确认安装                                        │
│  - 展示评估报告                                              │
│  - 展示安全扫描结果                                          │
│  - 用户明确确认                                              │
│  - 安装技能                                                  │
└─────────────────────────────────────────────────────────────┘
```

---

## 🛠️ 自动化脚本

### create_skill_scanner.sh

让我创建一个自动化的技能安全扫描脚本：

```bash
#!/bin/bash
# Skill 安全扫描脚本
# 用法：./scan_skill.sh <skill_github_url>

set -e

SKILL_URL="$1"
SKILL_NAME=$(basename "$SKILL_URL" .git)
WORKSPACE="/home/admin/.openclaw/workspace"
SCAN_DIR="$WORKSPACE/data/skills/scans"
REPORT_FILE="$SCAN_DIR/${SKILL_NAME}_scan_$(date '+%Y%m%d_%H%M').md"

mkdir -p "$SCAN_DIR"

echo "🔍 开始扫描技能：$SKILL_NAME"
echo "URL: $SKILL_URL"
echo ""

# 第 1 步：检查是否在 ClawHub 上
echo "📊 第 1 步：VirusTotal 检查..."
CLAWHUB_URL="https://clawhub.ai/skills/$SKILL_NAME"
if curl -s -o /dev/null -w "%{http_code}" "$CLAWHUB_URL" | grep -q "200"; then
    echo "✅ 技能在 ClawHub 上"
    echo "   请手动查看 VirusTotal 报告：$CLAWHUB_URL"
else
    echo "⚠️  技能不在 ClawHub 上，跳过 VirusTotal 检查"
fi
echo ""

# 第 2 步：Snyk 扫描（如果可用）
echo "🔍 第 2 步：Snyk Agent Scan..."
if command -v uvx &> /dev/null && [ -n "$SNYK_TOKEN" ]; then
    echo "   运行 Snyk 扫描..."
    # 这里需要 clone 仓库后扫描
    echo "   ⚠️  需要先 clone 技能仓库"
else
    echo "   ⚠️  Snyk 未配置，跳过"
    echo "   提示：export SNYK_TOKEN=your-token"
fi
echo ""

# 第 3 步：生成报告
cat > "$REPORT_FILE" << EOF
# Skill 安全扫描报告

## 基本信息
- **技能**: $SKILL_NAME
- **GitHub**: $SKILL_URL
- **扫描时间**: $(date '+%Y-%m-%d %H:%M')

## 扫描结果

### VirusTotal 检查
[待填写]

### Snyk Agent Scan
[待填写]

### 人工审查
[待填写]

## 安全评级
- [ ] ✅ 安全 - 可安装
- [ ] ⚠️  有风险 - 需审查
- [ ] ❌ 危险 - 禁止安装

## 用户确认
- [ ] 已阅读扫描报告
- [ ] 理解潜在风险
- [ ] 同意安装

**确认人**: ___________
**日期**: ___________
EOF

echo "✅ 扫描报告已生成：$REPORT_FILE"
```

---

## 📊 安全扫描配置

### 配置 Snyk Token

```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
export SNYK_TOKEN="your-snyk-token-here"

# 或者在 Gateway 环境中设置
openclaw configure --env SNYK_TOKEN=your-token
```

### 配置自动扫描

在 `HEARTBEAT.md` 中添加：

```markdown
### 安全扫描任务
- 每次安装 skill 前必须运行 Snyk 扫描
- 每周运行一次 security-audit.sh
- 发现新 skill 立即扫描
```

---

## 📚 相关资源

### 官方文档
- **Snyk Agent Scan**: https://github.com/snyk/agent-scan
- **VirusTotal API**: https://developers.virustotal.com/reference
- **ClawHub Security**: https://clawhub.ai/security

### 技术报告
- [Snyk Agent Skills Security Report](https://github.com/snyk/agent-scan/blob/main/.github/reports/skills-report.pdf)
- 检测 15+ 种安全风险的详细说明

### 本地脚本
- `skills/proactive-agent/scripts/security-audit.sh` - 本地安全审计
- `skills/proactive-agent/references/security-patterns.md` - 安全模式参考

---

## ✅ 推荐实施方案

### 立即可用（今天）

1. ✅ **配置 Snyk Agent Scan**
   ```bash
   export SNYK_TOKEN="your-token"
   uvx snyk-agent-scan@latest
   ```

2. ✅ **运行本地安全审计**
   ```bash
   ./skills/proactive-agent/scripts/security-audit.sh
   ```

3. ✅ **更新评估流程**
   - 在评估报告中添加安全扫描结果
   - 必须扫描通过才能安装

### 下周实施

1. ⏳ **创建自动化扫描脚本**
   - 一键扫描 + 生成报告
   - 集成到安装流程

2. ⏳ **配置定期扫描**
   - 每周扫描所有已安装技能
   - 发现新威胁立即告警

3. ⏳ **建立安全数据库**
   - 记录所有扫描结果
   - 建立技能黑白名单

---

## 🚨 安全红线

**❌ 绝对禁止**：
- 未扫描直接安装
- 忽略 Snyk E001-E006 级别问题
- 安装 VirusTotal 标记为风险的技能
- 跳过人工代码审查

**✅ 必须遵守**：
- 安装前必须运行完整扫描
- 发现高风险立即终止
- 所有扫描结果存档
- 用户确认后才能安装

---

**最后更新**: 2026-03-15  
**维护者**: OpenClaw Agent

**核心原则**: **安装前必须扫描，扫描通过才能安装！** 🛡️
