#!/usr/bin/env node

/**
 * 机器人启动时自动检查广播
 * 
 * 用法：在机器人启动脚本中调用
 * node broadcast/check-on-startup.js
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const BROADCAST_DIR = path.join(__dirname);
const PENDING_FILE = path.join(BROADCAST_DIR, 'pending.json');
const STATE_FILE = path.join(BROADCAST_DIR, '.bot-state.json');

function getBotId() {
  return process.env.MEMORY_NODE_ID || 'bot-2';
}

function loadPending() {
  if (!fs.existsSync(PENDING_FILE)) return { broadcasts: [] };
  return JSON.parse(fs.readFileSync(PENDING_FILE, 'utf8'));
}

function loadState() {
  if (!fs.existsSync(STATE_FILE)) return { repliedBroadcasts: [] };
  return JSON.parse(fs.readFileSync(STATE_FILE, 'utf8'));
}

function saveState(state) {
  fs.writeFileSync(STATE_FILE, JSON.stringify(state, null, 2));
}

function autoReply(broadcastId) {
  const botId = getBotId();
  const timestamp = new Date().toISOString();
  
  // 读取日志
  const logFile = path.join(BROADCAST_DIR, 'log.jsonl');
  let log = [];
  if (fs.existsSync(logFile)) {
    const content = fs.readFileSync(logFile, 'utf8');
    log = content.split('\n').filter(l => l.trim()).map(l => JSON.parse(l));
  }
  
  // 添加自动回复
  const reply = {
    type: 'reply',
    broadcastId,
    botId,
    timestamp,
    content: `[自动回复] 机器人 ${botId} 启动，已收到广播。`,
    status: 'confirmed',
  };
  
  log.push(reply);
  fs.writeFileSync(logFile, log.map(e => JSON.stringify(e)).join('\n') + '\n');
  
  // 更新待确认
  const pending = loadPending();
  const broadcast = pending.broadcasts.find(b => b.id === broadcastId);
  
  if (broadcast) {
    const existingReply = broadcast.replies.find(r => r.botId === botId);
    if (existingReply) {
      existingReply.timestamp = timestamp;
      existingReply.content = reply.content;
      existingReply.status = 'confirmed';
    } else {
      broadcast.replies.push({ botId, timestamp, content: reply.content, status: 'confirmed' });
    }
    
    // 检查是否全部确认
    const allConfirmed = broadcast.targets.every(target =>
      broadcast.replies.some(r => r.botId === target && r.status === 'confirmed')
    );
    
    if (allConfirmed) {
      broadcast.status = 'confirmed';
      broadcast.confirmedAt = timestamp;
    }
    
    fs.writeFileSync(PENDING_FILE, JSON.stringify(pending, null, 2));
  }
  
  // 更新状态
  const state = loadState();
  if (!state.repliedBroadcasts.includes(broadcastId)) {
    state.repliedBroadcasts.push(broadcastId);
    saveState(state);
  }
  
  console.log(`✅ 自动回复广播：${broadcastId}`);
}

function checkAndReply() {
  const botId = getBotId();
  const pending = loadPending();
  const state = loadState();
  
  console.log(`\n📢 检查广播 (机器人：${botId})\n`);
  
  const pendingBroadcasts = pending.broadcasts.filter(b => b.status === 'pending');
  
  if (pendingBroadcasts.length === 0) {
    console.log('✅ 无待确认广播');
    return;
  }
  
  let repliedCount = 0;
  
  for (const b of pendingBroadcasts) {
    // 检查是否已回复
    if (state.repliedBroadcasts.includes(b.id)) {
      console.log(`⏭️  已回复：${b.id} (${b.title})`);
      continue;
    }
    
    // 检查是否已经在广播中有回复记录
    const existingReply = b.replies.find(r => r.botId === botId);
    if (existingReply) {
      console.log(`⏭️  已回复：${b.id} (${b.title})`);
      state.repliedBroadcasts.push(b.id);
      saveState(state);
      continue;
    }
    
    // 自动回复
    console.log(`📢 新广播：${b.id} (${b.title})`);
    console.log(`   优先级：${b.priority}`);
    console.log(`   内容：${b.title}`);
    
    autoReply(b.id);
    repliedCount++;
  }
  
  if (repliedCount === 0) {
    console.log('\n✅ 所有广播已处理');
  } else {
    console.log(`\n✅ 已自动回复 ${repliedCount} 个广播`);
  }
}

// 主函数
if (require.main === module) {
  checkAndReply();
}

module.exports = { checkAndReply };
