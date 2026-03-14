---
name: chinese-document-generator
description: Generate Chinese-friendly PDF, Word, Excel, and PPT documents without乱码
metadata:
  {
    "openclaw": {
      "requires": { "bins": ["node"] },
      "primaryEnv": "DOCUMENT_API_KEY"
    }
  }
---

# Chinese Document Generator

This skill generates professional documents in multiple formats with full Chinese support.

## Supported Formats
- **PDF**: Professional PDF documents with Chinese text
- **Word (.docx)**: Microsoft Word compatible documents  
- **Excel (.xlsx)**: Spreadsheet files with data tables
- **PowerPoint (.pptx)**: Presentation slides

## Usage Examples

### Generate PDF
```json
{
  "tool": "generate-pdf",
  "title": "中文报告",
  "content": "这是PDF内容，支持中文无乱码。",
  "outputPath": "./report.pdf"
}
```

### Generate Word Document
```json
{
  "tool": "generate-word", 
  "title": "中文文档",
  "content": "这是Word文档内容。",
  "outputPath": "./document.docx"
}
```

### Generate Excel Spreadsheet
```json
{
  "tool": "generate-excel",
  "title": "数据表格",
  "data": [["姓名", "年龄"], ["张三", 25], ["李四", 30]],
  "outputPath": "./data.xlsx" 
}
```

### Generate PowerPoint
```json
{
  "tool": "generate-ppt",
  "title": "演示文稿",
  "slides": ["第一张幻灯片内容", "第二张幻灯片内容"],
  "outputPath": "./presentation.pptx"
}
```

## Features
- ✅ **UTF-8 Encoding**: Full Chinese character support
- ✅ **No Garbled Text**: Proper font handling
- ✅ **Professional Formatting**: Clean, readable output
- ✅ **Multiple Formats**: All major office document types

## Requirements
- Node.js (v14+)
- npm packages: pdfmake, xlsx, docx, pptxgenjs