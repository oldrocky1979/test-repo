const fs = require('fs');
const PptxGenJS = require('pptxgenjs');

function generatePPT(params) {
  const { title, slides, outputPath } = params;
  
  const pptx = new PptxGenJS();
  pptx.author = "OpenClaw";
  pptx.company = "Document Generator";
  
  // Title slide
  const titleSlide = pptx.addSlide();
  titleSlide.addText(title, { x: 1.5, y: 1.5, w: '80%', h: 1, fontSize: 28, bold: true });
  
  // Content slides
  slides.forEach(slideContent => {
    const slide = pptx.addSlide();
    slide.addText(slideContent, { x: 1, y: 1, w: '80%', h: '80%', fontSize: 18 });
  });
  
  // Save to file
  return new Promise((resolve, reject) => {
    try {
      pptx.writeFile({ fileName: outputPath });
      resolve({ success: true, outputPath });
    } catch (error) {
      reject(error);
    }
  });
}

module.exports = { generatePPT };