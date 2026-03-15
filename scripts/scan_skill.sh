#!/bin/bash
# Skill 安全扫描脚本 v1.0
# 用法：./scan_skill.sh <skill_github_url>
# ⚠️ 安装前必须扫描！

# 不使用 set -e，因为某些检查可能失败但需要继续执行
set +e

# 颜色定义
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 参数检查
if [ -z "$1" ]; then
    echo "用法：$0 <skill_github_url>"
    echo "示例：$0 https://github.com/xxx/skill-name"
    exit 1
fi

SKILL_URL="$1"
SKILL_NAME=$(basename "$SKILL_URL" .git)
WORKSPACE="/home/admin/.openclaw/workspace"
SCAN_DIR="$WORKSPACE/data/skills/scans"
REPORT_FILE="$SCAN_DIR/${SKILL_NAME}_scan_$(date '+%Y%m%d_%H%M').md"
TEMP_DIR="/tmp/skill_scan_$$"

# 创建目录
mkdir -p "$SCAN_DIR"
mkdir -p "$TEMP_DIR"

# 计数器
ISSUES=0
WARNINGS=0

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
    ((ISSUES++))
}

echo "========================================"
echo "🔍 Skill 安全扫描 | $SKILL_NAME"
echo "========================================"
echo ""

# 第 1 步：检查是否在 ClawHub 上
log_info "第 1 步：VirusTotal 检查（ClawHub）..."
CLAWHUB_URL="https://clawhub.ai/skills/$SKILL_NAME"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$CLAWHUB_URL" || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    log_success "技能在 ClawHub 上"
    echo "   请查看 VirusTotal 报告：$CLAWHUB_URL"
    echo "   ⚠️  如有风险标记，请终止安装！"
    VT_STATUS="available"
else
    log_warn "技能不在 ClawHub 上，跳过 VirusTotal 检查"
    VT_STATUS="not_available"
fi
echo ""

# 第 2 步：Clone 仓库进行扫描
log_info "第 2 步：Clone 技能仓库..."
git clone --depth 1 "$SKILL_URL" "$TEMP_DIR/$SKILL_NAME" 2>/dev/null || {
    log_error "无法 clone 仓库，请检查 URL 是否正确"
    exit 1
}
log_success "仓库已 clone 到 $TEMP_DIR/$SKILL_NAME"
echo ""

# 第 3 步：Snyk Agent Scan（如果可用）
log_info "第 3 步：Snyk Agent Scan..."
if command -v uvx &> /dev/null; then
    if [ -n "$SNYK_TOKEN" ]; then
        log_success "运行 Snyk 扫描..."
        
        # 扫描 SKILL.md
        if [ -f "$TEMP_DIR/$SKILL_NAME/SKILL.md" ]; then
            echo "   扫描 SKILL.md..."
            SNYK_RESULT=$(uvx snyk-agent-scan@latest "$TEMP_DIR/$SKILL_NAME/SKILL.md" 2>&1 || true)
            echo "$SNYK_RESULT"
            
            # 检查结果
            if echo "$SNYK_RESULT" | grep -q "❌.*E00[1-6]"; then
                log_error "Snyk 发现严重安全问题！"
                echo "$SNYK_RESULT" | grep "❌"
            fi
            
            if echo "$SNYK_RESULT" | grep -q "⚠️"; then
                log_warn "Snyk 发现潜在风险"
                echo "$SNYK_RESULT" | grep "⚠️"
            fi
        else
            log_warn "未找到 SKILL.md 文件"
        fi
        
        # 扫描 scripts 目录
        if [ -d "$TEMP_DIR/$SKILL_NAME/scripts" ]; then
            echo "   扫描 scripts/ 目录..."
            # 可以添加更多扫描逻辑
        fi
    else
        log_warn "SNYK_TOKEN 未设置，跳过 Snyk 扫描"
        echo "   提示：export SNYK_TOKEN=your-token"
    fi
else
    log_warn "uvx 未安装，跳过 Snyk 扫描"
    echo "   安装：curl -LsSf https://astral.sh/uv/install.sh | sh"
fi
echo ""

# 第 4 步：本地安全检查
log_info "第 4 步：本地安全检查..."

# 检查 SKILL.md 中的危险模式
if [ -f "$TEMP_DIR/$SKILL_NAME/SKILL.md" ]; then
    echo "   检查 SKILL.md..."
    
    # 检查 prompt injection 模式
    if grep -qi "ignore previous\|disregard\|new system prompt\|admin override" "$TEMP_DIR/$SKILL_NAME/SKILL.md" 2>/dev/null; then
        log_error "发现可能的 prompt injection 模式！"
    fi
    
    # 检查危险命令
    if grep -qi "rm -rf\|curl.*bash\|wget.*bash\|sudo\|chmod 777" "$TEMP_DIR/$SKILL_NAME/SKILL.md" 2>/dev/null; then
        log_error "发现危险命令模式！"
    fi
    
    # 检查硬编码密钥
    if grep -qiE "(api[_-]?key|apikey|secret|password|token)[[:space:]]*[=:][[:space:]]*[\"'][^\"']{10,}" "$TEMP_DIR/$SKILL_NAME/SKILL.md" 2>/dev/null; then
        log_error "发现可能的硬编码密钥！"
    fi
    
    log_success "SKILL.md 检查完成"
fi

# 检查 scripts 目录
if [ -d "$TEMP_DIR/$SKILL_NAME/scripts" ]; then
    echo "   检查 scripts/ 目录..."
    
    # 查找所有 shell 脚本
    for script in "$TEMP_DIR/$SKILL_NAME/scripts"/*.sh; do
        if [ -f "$script" ]; then
            echo "      检查 $(basename $script)..."
            
            # 检查危险命令
            if grep -q "rm -rf\|curl.*bash\|wget.*bash" "$script" 2>/dev/null; then
                log_error "$(basename $script) 包含危险命令！"
            fi
            
            # 检查硬编码密钥
            if grep -qiE "(api[_-]?key|secret|password|token)[[:space:]]*[=:]" "$script" 2>/dev/null; then
                log_warn "$(basename $script) 可能包含硬编码密钥"
            fi
        fi
    done
    
    log_success "scripts/ 检查完成"
fi

# 检查权限需求
if [ -f "$TEMP_DIR/$SKILL_NAME/SKILL.md" ]; then
    echo "   检查权限需求..."
    
    if grep -qi "elevated\|sudo\|root" "$TEMP_DIR/$SKILL_NAME/SKILL.md" 2>/dev/null; then
        log_warn "技能需要提权权限，需人工审查"
    fi
    
    if grep -qi "message send\|web_search\|exec" "$TEMP_DIR/$SKILL_NAME/SKILL.md" 2>/dev/null; then
        echo "      技能使用标准工具权限"
    fi
fi

echo ""

# 第 5 步：生成报告
log_info "第 5 步：生成扫描报告..."

cat > "$REPORT_FILE" << EOF
# Skill 安全扫描报告

## 基本信息
- **技能**: $SKILL_NAME
- **GitHub**: $SKILL_URL
- **扫描时间**: $(date '+%Y-%m-%d %H:%M')
- **扫描工具**: security-scan.sh v1.0

## 扫描结果

### 1. VirusTotal 检查
- **ClawHub 状态**: $VT_STATUS
- **检查结果**: $([ "$VT_STATUS" = "available" ] && echo "✅ 请手动查看 ClawHub 页面" || echo "⚠️  技能不在 ClawHub 上")

### 2. Snyk Agent Scan
$([ -n "$SNYK_TOKEN" ] && command -v uvx &> /dev/null && echo "✅ 已执行" || echo "⚠️  未执行（缺少 SNYK_TOKEN 或 uvx）")

### 3. 本地安全检查
- **Prompt Injection**: $([ $ISSUES -eq 0 ] && echo "✅ 未发现" || echo "❌ 发现 $ISSUES 个问题")
- **危险命令**: 已检查
- **硬编码密钥**: 已检查

## 问题统计
- **严重问题**: $ISSUES 个
- **警告**: $WARNINGS 个

## 安全评级
EOF

if [ $ISSUES -gt 0 ]; then
    cat >> "$REPORT_FILE" << EOF
### ❌ 危险 - 禁止安装

发现 $ISSUES 个严重安全问题，**禁止安装**！

请修复所有问题后重新扫描。
EOF
    RECOMMENDATION="DO_NOT_INSTALL"
elif [ $WARNINGS -gt 0 ]; then
    cat >> "$REPORT_FILE" << EOF
### ⚠️  有风险 - 需人工审查

发现 $WARNINGS 个警告，**需要人工审查**后决定是否安装。

请仔细审查警告内容，确认无风险后再安装。
EOF
    RECOMMENDATION="REVIEW_REQUIRED"
else
    cat >> "$REPORT_FILE" << EOF
### ✅ 安全 - 可安装

未发现安全问题，**可以安装**。

仍建议进行人工代码审查确认。
EOF
    RECOMMENDATION="SAFE_TO_INSTALL"
fi

cat >> "$REPORT_FILE" << EOF

## 用户确认
- [ ] 已阅读扫描报告
- [ ] 理解潜在风险
- [ ] 同意安装

**确认人**: ___________
**日期**: ___________

---
_扫描器：security-scan.sh v1.0_
_扫描时间：$(date '+%Y-%m-%d %H:%M')_
EOF

log_success "扫描报告已生成：$REPORT_FILE"
echo ""

# 清理临时文件
rm -rf "$TEMP_DIR"

# 总结
echo "========================================"
echo "📊 扫描总结"
echo "========================================"
if [ $ISSUES -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ 所有检查通过！可以安装${NC}"
elif [ $ISSUES -eq 0 ]; then
    echo -e "${YELLOW}⚠️  $WARNINGS 个警告，需人工审查${NC}"
else
    echo -e "${RED}❌ $ISSUES 个严重问题，禁止安装！${NC}"
fi
echo ""
echo "详细报告：$REPORT_FILE"
echo "========================================"
echo ""

# 返回状态码
if [ $ISSUES -gt 0 ]; then
    exit 1
else
    exit 0
fi
