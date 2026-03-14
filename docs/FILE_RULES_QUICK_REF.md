# 📎 文件推送规则 - 快速参考

**规则**: 所有生成的文件必须**直接发送到会话中**，不得发送路径链接。

---

## ✅ 正确做法

```javascript
// 1. 生成文件
await generatePdf({title, content, outputPath});

// 2. 读取文件
const buffer = fs.readFileSync(outputPath);
const base64 = buffer.toString('base64');

// 3. 发送到会话（带附件）
{
  "tool": "message",
  "action": "send",
  "message": "报告已生成，请查收附件。",
  "buffer": "data:application/pdf;base64,{base64}",
  "filename": "报告_2026-03-14.pdf"
}
```

---

## ❌ 错误做法

```javascript
// ❌ 只发送路径（禁止！）
{
  "tool": "message",
  "action": "send",
  "message": "文件已生成：/home/admin/workspace/report.pdf"
}
```

---

## 📄 常见 MIME 类型

| 文件类型 | MIME Type |
|---------|-----------|
| PDF | `application/pdf` |
| Word | `application/vnd.openxmlformats-officedocument.wordprocessingml.document` |
| Excel | `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` |
| PowerPoint | `application/vnd.openxmlformats-officedocument.presentationml.presentation` |
| PNG 图片 | `image/png` |
| JPEG 图片 | `image/jpeg` |
| 文本 | `text/plain` |

---

## 📝 文件命名模板

```
{内容类型}_{YYYY-MM-DD}.{扩展名}
```

**示例**:
- `服务器日报_2026-03-14.pdf`
- `股票监控_2026-03-14.xlsx`
- `早间新闻_2026-03-14.docx`

---

## ⚠️ 注意事项

1. **文件大小**: < 20MB (推荐)
2. **必须指定 filename 参数**
3. **使用 buffer 发送，不是路径**
4. **发送后清理临时文件**

---

**详细文档**: `/home/admin/.openclaw/workspace/docs/file_delivery_protocol.md`
