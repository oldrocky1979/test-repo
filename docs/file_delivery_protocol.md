# 📎 文件推送协议 v1.0

**生效时间**: 2026-03-14
**适用范围**: 所有文件生成任务

---

## 📋 核心规则

### ✅ 必须遵守的规则

**所有生成的文件必须直接发送到会话中，不得以路径链接形式发送。**

---

## ❌ 禁止的做法

```markdown
❌ 错误示例 1: 发送文件路径
文件已生成：/home/admin/.openclaw/workspace/data/report.pdf
请自行查看。

❌ 错误示例 2: 发送本地链接
报告已创建：[点击这里查看](file:///home/admin/.openclaw/workspace/data/report.pdf)

❌ 错误示例 3: 只告知位置
PDF 文件在 ./data/news/ 目录下
```

---

## ✅ 正确的做法

### 方法 1: 使用 message 工具的 buffer 参数

```javascript
// 读取生成的文件
const fs = require('fs');
const fileBuffer = fs.readFileSync('./report.pdf');
const base64Content = fileBuffer.toString('base64');

// 直接发送文件到会话
{
  "tool": "message",
  "action": "send",
  "channel": "feishu",
  "account": "bot-2",
  "target": "user:ou_c051a3ac336ce444b19011d44bbd7ff1",
  "message": "📄 **服务器日报** | 2026-03-14\n\n今日服务器运行情况报告已生成，请查收附件。",
  "buffer": "data:application/pdf;base64,{base64Content}",
  "filename": "服务器日报_2026-03-14.pdf"
}
```

### 方法 2: 使用 OpenClaw CLI

```bash
# 直接发送文件到会话
openclaw message send \
  --channel feishu \
  --account bot-2 \
  --target "user:ou_c051a3ac336ce444b19011d44bbd7ff1" \
  --message "📄 服务器日报已生成" \
  --file "./report.pdf"
```

---

## 📊 不同平台的文件发送方式

### Feishu (飞书)

```javascript
{
  "tool": "message",
  "action": "send",
  "channel": "feishu",
  "buffer": "data:application/pdf;base64,{base64}",
  "filename": "report.pdf",
  "message": "报告已生成，请查收附件。"
}
```

**支持的文件类型**:
- 📄 PDF: `application/pdf`
- 📝 Word: `application/vnd.openxmlformats-officedocument.wordprocessingml.document`
- 📊 Excel: `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`
- 📽️ PowerPoint: `application/vnd.openxmlformats-officedocument.presentationml.presentation`
- 🖼️ 图片：`image/png`, `image/jpeg`
- 📝 文本：`text/plain`

### Discord

```javascript
{
  "tool": "message",
  "action": "send",
  "channel": "discord",
  "buffer": "data:application/pdf;base64,{base64}",
  "filename": "report.pdf"
}
```

### Telegram

```javascript
{
  "tool": "message",
  "action": "send",
  "channel": "telegram",
  "buffer": "data:application/pdf;base64,{base64}",
  "filename": "report.pdf"
}
```

### WhatsApp

```javascript
{
  "tool": "message",
  "action": "send",
  "channel": "whatsapp",
  "buffer": "data:application/pdf;base64,{base64}",
  "filename": "report.pdf"
}
```

---

## 🎯 完整工作流程示例

### 示例 1: 服务器日报 PDF

```javascript
// 1. 生成 PDF
const {generatePdf} = require('./tools/generate-pdf.js');
await generatePdf({
  title: "服务器日报",
  content: "今日服务器运行情况...",
  outputPath: "/tmp/server_report.pdf"
});

// 2. 读取文件
const fs = require('fs');
const fileBuffer = fs.readFileSync('/tmp/server_report.pdf');
const base64Content = fileBuffer.toString('base64');

// 3. 发送到会话
{
  "tool": "message",
  "action": "send",
  "channel": "feishu",
  "account": "bot-2",
  "target": "user:ou_c051a3ac336ce444b19011d44bbd7ff1",
  "message": "🖥️ **服务器日报** | 2026-03-14\n\nCPU: 25% 🟢\n内存：51% 🟢\n磁盘：24% 🟢\n\n详细报告请见附件。",
  "buffer": `data:application/pdf;base64,${base64Content}`,
  "filename": "服务器日报_2026-03-14.pdf"
}

// 4. 清理临时文件（可选）
fs.unlinkSync('/tmp/server_report.pdf');
```

### 示例 2: 股票分析 Excel

```javascript
// 1. 生成 Excel
const {generateExcel} = require('./tools/generate-excel.js');
await generateExcel({
  title: "股票监控日报",
  data: [
    ["股票", "价格", "涨跌幅"],
    ["贵州茅台", "¥1735", "+2.09%"],
    ["腾讯控股", "HK$525", "+1.5%"]
  ],
  outputPath: "/tmp/stocks.xlsx"
});

// 2. 读取并发送
const fileBuffer = fs.readFileSync('/tmp/stocks.xlsx');
const base64Content = fileBuffer.toString('base64');

{
  "tool": "message",
  "action": "send",
  "channel": "feishu",
  "account": "bot-2",
  "target": "user:ou_c051a3ac336ce444b19011d44bbd7ff1",
  "message": "📊 **股票监控日报** | 2026-03-14\n\n共监控 8 只股票，2 只超过预警阈值。\n\n详细数据请见附件。",
  "buffer": `data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,${base64Content}`,
  "filename": "股票监控_2026-03-14.xlsx"
}
```

### 示例 3: 新闻汇总 Word

```javascript
// 1. 生成 Word
const {generateWord} = require('./tools/generate-word.js');
await generateWord({
  title: "早间新闻汇总",
  content: "今日重要新闻内容...",
  outputPath: "/tmp/news.docx"
});

// 2. 读取并发送
const fileBuffer = fs.readFileSync('/tmp/news.docx');
const base64Content = fileBuffer.toString('base64');

{
  "tool": "message",
  "action": "send",
  "channel": "feishu",
  "account": "bot-2",
  "target": "user:ou_c051a3ac336ce444b19011d44bbd7ff1",
  "message": "📰 **早间新闻汇总** | 2026-03-14\n\n• 全球时事：5 条\n• 科技前沿：5 条\n• 人工智能：5 条\n• 金融经济：5 条\n\n完整报告请见附件。",
  "buffer": `data:application/vnd.openxmlformats-officedocument.wordprocessingml.document;base64,${base64Content}`,
  "filename": "早间新闻_2026-03-14.docx"
}
```

---

## 📏 文件大小限制

| 平台 | 最大文件大小 | 建议 |
|------|------------|------|
| Feishu | 100 MB | < 20 MB |
| Discord | 25 MB (免费) | < 10 MB |
| Telegram | 2 GB | < 50 MB |
| WhatsApp | 100 MB | < 20 MB |

**优化建议**:
- PDF 文件：压缩图片，使用简洁格式
- Excel 文件：避免过多公式和格式
- 超大文件：分拆为多个文件或提供下载链接

---

## 🔧 错误处理

### 文件读取失败

```javascript
try {
  const fileBuffer = fs.readFileSync(filePath);
  // 发送文件...
} catch (error) {
  // 发送错误通知（不带附件）
  {
    "tool": "message",
    "action": "send",
    "channel": "feishu",
    "message": "❌ **文件生成失败**\n\n错误信息：" + error.message + "\n\n已记录日志，稍后重试。"
  }
}
```

### 文件过大

```javascript
const MAX_FILE_SIZE = 20 * 1024 * 1024; // 20MB

if (fileBuffer.length > MAX_FILE_SIZE) {
  // 压缩或分拆文件
  // 或者发送通知
  {
    "tool": "message",
    "action": "send",
    "message": "⚠️ **文件过大提醒**\n\n生成的文件超过 20MB，已自动压缩。\n如需要完整版本，请告知。"
  }
}
```

---

## 📝 文件命名规范

### 推荐格式
```
{内容类型}_{日期}.{扩展名}
```

### 示例
- `服务器日报_2026-03-14.pdf`
- `股票监控_2026-03-14.xlsx`
- `早间新闻_2026-03-14.docx`
- `审计报告_2026-Q1.pptx`

### 避免的命名
- ❌ `report.pdf` (太模糊)
- ❌ `新建文档 1.docx` (不专业)
- ❌ `test.xlsx` (测试文件不应发送)
- ❌ 包含空格和特殊字符

---

## ✅ 检查清单

在发送文件前，请确认：

- [ ] 文件已成功生成
- [ ] 文件可以正常打开
- [ ] 文件大小在限制范围内
- [ ] 文件命名清晰专业
- [ ] 消息说明简洁明了
- [ ] 使用 buffer 直接发送（不是路径）
- [ ] 指定了正确的 MIME 类型
- [ ] 指定了文件名（filename 参数）

---

## 🚫 违规处理

**如发现发送文件路径而非文件本身**:

1. **立即纠正**: 重新发送文件附件
2. **记录原因**: 为什么没有直接发送文件
3. **更新流程**: 避免再次发生

---

**本规则自 2026-03-14 起生效，所有文件生成任务必须遵守。** 📎
