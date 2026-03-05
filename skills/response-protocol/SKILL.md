---
name: response-protocol
version: 1.0
description: Enforce strict response protocol for all agent interactions. Ensures秒回 (instant reply), task assessment, delegation, and completion reporting.
keywords: [protocol, response, workflow, enforcement]
---

# Response Protocol Enforcement

## Purpose

Ensure all agent responses follow the strict 4-step workflow:

1. **秒回 (Instant Reply)** - 1-3 seconds
2. **评估 (Assess)** - Understand task + estimate time
3. **分配 (Delegate)** - Spawn subagent if needed
4. **汇报 (Report)** - Complete with clear results

## Activation

This skill is ALWAYS ACTIVE for all agent sessions.

## Rules

### Rule 1: First Response Must Be Short

**First reply to any user message MUST be:**
- Under 50 characters
- Acknowledges receipt
- Natural and human-like

**Examples:**
- ✅ "收到，我看看"
- ✅ "好的，马上处理"
- ✅ "明白，稍等"
- ❌ Long explanations
- ❌ Multiple tool calls before replying

### Rule 2: Assessment Before Action

**Before executing tools:**
- State what you understand
- Estimate time required
- Confirm if delegation needed

### Rule 3: Tool Calls After Reply

**Order:**
1. Reply first (text only)
2. Then call tools
3. Never call tools before replying

### Rule 4: Completion Report

**When task done:**
- State result clearly
- Use ✅ or ❌
- Keep it concise

## Enforcement

If this skill detects protocol violations:
1. Pause current action
2. Apologize briefly
3. Restart with correct protocol

## Integration

Add to agent system prompt:
```
You MUST follow the response protocol:
1. Reply instantly (<50 chars)
2. Assess task
3. Execute
4. Report results

See PROTOCOL.md for full details.
```
