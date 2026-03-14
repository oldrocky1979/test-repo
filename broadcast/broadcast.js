#!/usr/bin/env node

/**
 * OpenClaw 广播系统 v1.0
 * 
 * 用于机器人之间的通知广播和回复确认
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const BROADCAST_DIR = path.join(__dirname);
const LOG_FILE = path.join(BROADCAST_DIR, 'log.jsonl');
const PENDING_FILE = path.join(BROADCAST_DIR, 'pending.json');

// ============================================================================
// 工具函数
// ============================================================================

function generateId() {
  const num = Math.floor(Date.now() / 1000) % 100000;
  return `broadcast-${String(num).padStart(3, '0')}`;
}

function loadLog() {
  if (!fs.existsSync(LOG_FILE)) return [];
  const content = fs.readFileSync(LOG_FILE, 'utf8');
  return content.split('\n')
    .filter(l => l.trim())
    .map(l => JSON.parse(l));
}

function saveLog(entries) {
  const content = entries.map(e => JSON.stringify(e)).join('\n') + '\n';
  fs.writeFileSync(LOG_FILE, content);
}

function loadPending() {
  if (!fs.existsSync(PENDING_FILE)) {
    return { broadcasts: [], lastUpdated: new Date().toISOString() };
  }
  return JSON.parse(fs.readFileSync(PENDING_FILE, 'utf8'));
}

function savePending(data) {
  data.lastUpdated = new Date().toISOString();
  fs.writeFileSync(PENDING_FILE, JSON.stringify(data, null, 2));
}

function getBotId() {
  return process.env.MEMORY_NODE_ID || 'bot-2';
}

// ============================================================================
// 广播功能
// ============================================================================

function createBroadcast(options) {
  const { title, priority, content, requiresReply, documentRef } = options;
  
  const broadcast = {
    type: 'broadcast',
    id: generateId(),
    timestamp: new Date().toISOString(),
    title,
    priority: priority || 'normal',
    content,
    sender: getBotId(),
    targets: ['bot-1', 'bot-2', 'bot-4', 'bot-6'],
    requiresReply: requiresReply !== false,
    documentRef: documentRef || null,
  };
  
  // 添加到日志
  const log = loadLog();
  log.push(broadcast);
  saveLog(log);
  
  // 添加到待确认
  const pending = loadPending();
  pending.broadcasts.push({
    id: broadcast.id,
    title: broadcast.title,
    priority: broadcast.priority,
    createdAt: broadcast.timestamp,
    targets: broadcast.targets,
    replies: [{ botId: getBotId(), timestamp: broadcast.timestamp, status: 'confirmed' }],
    status: 'pending',
  });
  savePending(pending);
  
  console.log(`✅ 广播已创建: ${broadcast.id}`);
  console.log(`   标题：${title}`);
  console.log(`   优先级：${priority}`);
  console.log(`   需要回复：${requiresReply !== false ? '是' : '否'}`);
  console.log(`   目标：${broadcast.targets.join(', ')}`);
  
  return broadcast;
}

function replyToBroadcast(broadcastId, content) {
  const botId = getBotId();
  const timestamp = new Date().toISOString();
  
  const reply = {
    type: 'reply',
    broadcastId,
    botId,
    timestamp,
    content,
    status: 'confirmed',
  };
  
  // 添加到日志
  const log = loadLog();
  log.push(reply);
  saveLog(log);
  
  // 更新待确认
  const pending = loadPending();
  const broadcast = pending.broadcasts.find(b => b.id === broadcastId);
  
  if (broadcast) {
    // 检查是否已回复
    const existingReply = broadcast.replies.find(r => r.botId === botId);
    if (existingReply) {
      existingReply.timestamp = timestamp;
      existingReply.content = content;
      existingReply.status = 'confirmed';
    } else {
      broadcast.replies.push({ botId, timestamp, content, status: 'confirmed' });
    }
    
    // 检查是否全部确认
    const allConfirmed = broadcast.targets.every(target =>
      broadcast.replies.some(r => r.botId === target && r.status === 'confirmed')
    );
    
    if (allConfirmed) {
      broadcast.status = 'confirmed';
      broadcast.confirmedAt = timestamp;
      console.log(`✅ 广播 ${broadcastId} 已全部确认！`);
    } else {
      broadcast.status = 'pending';
    }
    
    savePending(pending);
  }
  
  console.log(`✅ 回复已提交: ${broadcastId}`);
  console.log(`   机器人：${botId}`);
  console.log(`   内容：${content}`);
  
  return reply;
}

function showStatus() {
  const pending = loadPending();
  
  console.log('\n📊 广播状态\n');
  console.log('='.repeat(60));
  
  if (pending.broadcasts.length === 0) {
    console.log('暂无广播');
    return;
  }
  
  for (const b of pending.broadcasts) {
    const statusIcon = b.status === 'confirmed' ? '✅' : '⏳';
    console.log(`\n${statusIcon} ${b.id}: ${b.title}`);
    console.log(`   优先级：${b.priority}`);
    console.log(`   创建时间：${b.createdAt}`);
    console.log(`   状态：${b.status}`);
    console.log(`   回复进度：${b.replies.length}/${b.targets.length}`);
    
    if (b.replies.length > 0) {
      console.log(`   已回复:`);
      for (const r of b.replies) {
        console.log(`     - ${r.botId}: ${r.status} (${r.timestamp})`);
      }
    }
    
    const pendingTargets = b.targets.filter(t =>
      !b.replies.some(r => r.botId === t && r.status === 'confirmed')
    );
    
    if (pendingTargets.length > 0) {
      console.log(`   待回复：${pendingTargets.join(', ')}`);
    }
  }
  
  console.log('\n' + '='.repeat(60));
}

function showPending() {
  const pending = loadPending();
  const pendingBroadcasts = pending.broadcasts.filter(b => b.status === 'pending');
  
  console.log('\n⏳ 待确认广播\n');
  
  if (pendingBroadcasts.length === 0) {
    console.log('暂无待确认广播');
    return;
  }
  
  for (const b of pendingBroadcasts) {
    const pendingTargets = b.targets.filter(t =>
      !b.replies.some(r => r.botId === t && r.status === 'confirmed')
    );
    
    console.log(`\n${b.id}: ${b.title}`);
    console.log(`   优先级：${b.priority}`);
    console.log(`   待回复：${pendingTargets.join(', ')}`);
  }
}

function archiveOld() {
  const pending = loadPending();
  const now = new Date();
  
  const toArchive = pending.broadcasts.filter(b => {
    if (b.status !== 'confirmed') return false;
    const createdAt = new Date(b.createdAt);
    const days = (now - createdAt) / (1000 * 60 * 60 * 24);
    return days > 30;
  });
  
  if (toArchive.length === 0) {
    console.log('暂无需要归档的广播');
    return;
  }
  
  // 创建归档目录
  const archiveDir = path.join(BROADCAST_DIR, 'archive', now.toISOString().slice(0, 7));
  if (!fs.existsSync(archiveDir)) {
    fs.mkdirSync(archiveDir, { recursive: true });
  }
  
  // 归档
  for (const b of toArchive) {
    const archiveFile = path.join(archiveDir, `${b.id}.json`);
    const log = loadLog().filter(e =>
      e.id === b.id || (e.broadcastId === b.id && e.type === 'reply')
    );
    fs.writeFileSync(archiveFile, JSON.stringify(log, null, 2));
    console.log(`📦 已归档：${b.id}`);
  }
  
  // 从待确认中移除
  pending.broadcasts = pending.broadcasts.filter(b => !toArchive.find(a => a.id === b.id));
  savePending(pending);
  
  console.log(`\n共归档 ${toArchive.length} 个广播`);
}

// ============================================================================
// CLI
// ============================================================================

function main() {
  const args = process.argv.slice(2);
  const command = args[0];
  
  switch (command) {
    case 'create': {
      const options = {};
      for (let i = 1; i < args.length; i++) {
        if (args[i] === '--title') options.title = args[++i];
        else if (args[i] === '--priority') options.priority = args[++i];
        else if (args[i] === '--content') options.content = args[++i];
        else if (args[i] === '--requires-reply') options.requiresReply = args[++i] !== 'false';
        else if (args[i] === '--document-ref') options.documentRef = args[++i];
      }
      
      if (!options.title || !options.content) {
        console.error('错误：必须提供 --title 和 --content');
        process.exit(1);
      }
      
      createBroadcast(options);
      break;
    }
    
    case 'reply': {
      let broadcastId, content;
      for (let i = 1; i < args.length; i++) {
        if (args[i] === '--broadcast-id') broadcastId = args[++i];
        else if (args[i] === '--content') content = args[++i];
      }
      
      if (!broadcastId || !content) {
        console.error('错误：必须提供 --broadcast-id 和 --content');
        process.exit(1);
      }
      
      replyToBroadcast(broadcastId, content);
      break;
    }
    
    case 'status':
      showStatus();
      break;
    
    case 'pending':
      showPending();
      break;
    
    case 'archive':
      archiveOld();
      break;
    
    default:
      console.log(`
OpenClaw 广播系统 v1.0

命令:
  create              创建广播
  reply               回复广播
  status              查看所有广播状态
  pending             查看待确认广播
  archive             归档旧广播

示例:
  node broadcast.js create --title "协议生效" --priority high --content "内容" --requires-reply true
  node broadcast.js reply --broadcast-id "broadcast-001" --content "已收到"
  node broadcast.js status
  node broadcast.js pending
  node broadcast.js archive
`);
  }
}

if (require.main === module) {
  main();
}

module.exports = {
  createBroadcast,
  replyToBroadcast,
  showStatus,
  showPending,
};
