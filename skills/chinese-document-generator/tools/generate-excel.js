const fs = require('fs');
const XLSX = require('xlsx');

function generateExcel(params) {
  const { title, data, outputPath } = params;
  
  // Create workbook and worksheet
  const wb = XLSX.utils.book_new();
  const ws = XLSX.utils.aoa_to_sheet(data);
  
  // Add worksheet to workbook
  XLSX.utils.book_append_sheet(wb, ws, title || 'Sheet1');
  
  // Write to file
  XLSX.writeFile(wb, outputPath);
  
  return { success: true, outputPath };
}

module.exports = { generateExcel };