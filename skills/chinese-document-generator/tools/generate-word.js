const fs = require('fs');
const { Document, Paragraph, TextRun, HeadingLevel, Packer } = require('docx');

function generateWord(params) {
  const { title, content, outputPath } = params;
  
  const doc = new Document({
    sections: [{
      properties: {},
      children: [
        new Paragraph({
          text: title,
          heading: HeadingLevel.HEADING_1,
        }),
        new Paragraph({
          children: [
            new TextRun({
              text: content,
              size: 24,
              font: "Microsoft YaHei, SimHei, sans-serif"
            })
          ]
        })
      ]
    }]
  });

  return Packer.toBuffer(doc).then((buffer) => {
    fs.writeFileSync(outputPath, buffer);
    return { success: true, outputPath };
  });
}

module.exports = { generateWord };