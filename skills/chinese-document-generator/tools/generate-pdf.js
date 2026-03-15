const fs = require('fs');
const path = require('path');

// 简化版 PDF 生成，使用 html-pdf（更兼容中文）
const pdf = require('html-pdf');

function generatePDF(params) {
  const { title, content, outputPath } = params;
  
  // 创建 HTML 内容，确保 UTF-8 和中文字体
  const htmlContent = `
    <!DOCTYPE html>
    <html lang="zh-CN">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${title}</title>
        <style>
            body {
                font-family: "Microsoft YaHei", "SimSun", "sans-serif";
                font-size: 14px;
                line-height: 1.6;
                margin: 40px;
            }
            h1 {
                font-size: 24px;
                margin-bottom: 20px;
            }
            p {
                margin: 10px 0;
            }
        </style>
    </head>
    <body>
        <h1>${title}</h1>
        <p>${content}</p>
    </body>
    </html>
  `;
  
  const options = {
    format: 'A4',
    orientation: 'portrait',
    border: {
      top: '1cm',
      right: '1cm',
      bottom: '1cm',
      left: '1cm'
    }
  };
  
  return new Promise((resolve, reject) => {
    pdf.create(htmlContent, options).toFile(outputPath, (err, res) => {
      if (err) {
        reject(err);
      } else {
        resolve({ success: true, outputPath });
      }
    });
  });
}

module.exports = { generatePDF };