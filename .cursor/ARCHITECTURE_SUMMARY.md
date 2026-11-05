# Agent架构实现总结

## 🎯 核心问题与解决方案

### 问题：不同Agent需要不同的记忆策略

| Agent类型 | 记忆需求 | 解决方案 | 状态 |
|----------|---------|---------|------|
| 🔍 Scanning | 避免重复挖掘 | 单例长期Agent | ✅ 已实现 |
| 💻 Development | Issue独立上下文 | 每Issue一个Agent | ✅ 已实现 |
| 🔀 Integration | 跨PR历史记忆 | 单例长期Agent | 📋 待实现 |

---

## 📐 架构图

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Repository                         │
│                                                              │
│  Variables (持久化存储):                                      │
│  ├─ SCANNING_AGENT_ID=bc-xxx                                │
│  └─ INTEGRATION_AGENT_ID=bc-yyy (未来)                       │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│  Scanning     │  │  Development  │  │ Integration   │
│  Agent        │  │  Agents       │  │ Agent         │
│  (单例)       │  │  (多实例)     │  │ (单例)        │
└───────────────┘  └───────────────┘  └───────────────┘
      │                   │                   │
      │                   │                   │
每日定时触发          /approve触发         PR创建触发
      │                   │                   │
      ▼                   ▼                   ▼
 ┌─────────┐         ┌─────────┐        ┌─────────┐
 │follow-up│         │新Agent  │        │follow-up│
 │到同一个 │         │每个Issue│        │到同一个 │
 │Agent    │         │独立     │        │Agent    │
 └─────────┘         └─────────┘        └─────────┘
```

---

## 🔄 完整工作流

### 第1天：初始化

```
1. 定时触发 daily-scan-with-cursor.yml
   ↓
2. 检测 SCANNING_AGENT_ID (不存在)
   ↓
3. 创建新 Scanning Agent
   ↓
4. 保存 SCANNING_AGENT_ID 到 Repository Variables
   ↓
5. Agent扫描代码，创建3个Issues
```

### 第2天：复用Agent

```
1. 定时触发 daily-scan-with-cursor.yml
   ↓
2. 检测 SCANNING_AGENT_ID (存在！)
   ↓
3. 发送 follow-up 到已有 Scanning Agent
   ↓
4. Agent记得昨天扫描过什么
   ↓
5. 只创建新的、未重复的Issues
```

### 开发流程

```
Issue #1: 添加登录功能
   ↓ 评论 /approve
创建 Development Agent #1
   ↓ agent:bc-aaa 标签
开发并创建 PR #1
   ↓ PR评论 @agent 需要加密
Agent #1 follow-up 修改代码
   ↓
合并 PR #1

同时...

Issue #2: 优化数据库
   ↓ 评论 /approve
创建 Development Agent #2
   ↓ agent:bc-bbb 标签
独立开发，不受 Agent #1 影响
```

---

## 🛠️ 管理工具

### 重置Agent

当Scanning Agent的"记忆"出现问题时：

1. 访问：`Actions` → `重置Agent（管理工具）`
2. 选择：`scanning`
3. 点击：`Run workflow`

下次运行将创建全新的Scanning Agent。

### 查看Agent状态

```bash
# 查看当前Scanning Agent ID
gh variable get SCANNING_AGENT_ID

# 查看Agent Dashboard
# https://cursor.com/agents/bc-xxx
```

---

## 📊 记忆内容对比

### Scanning Agent的记忆

```
第1天：
- 扫描了 src/ 目录
- 发现3个TODO
- 创建了Issue #1, #2, #3

第2天（有记忆）：
- 记得昨天扫描过 src/
- 发现 src/ 没有新TODO
- 扫描 tests/ 目录（新的）
- 只创建新Issue #4
```

### Development Agent的记忆

```
Issue #5: 添加搜索功能

Agent记忆：
- Issue描述：需要支持全文搜索
- PR评论1：加上分页
- PR评论2：优化性能
- 代码修改历史
- 测试结果

独立于其他Issue的Agent
```

---

## ⚡ 性能优化

### API调用次数

**优化前：**
- 每次扫描：创建新Agent = 读取全部代码
- 成本：高

**优化后：**
- 首次扫描：创建Agent = 读取全部代码
- 后续扫描：follow-up = Agent已有上下文
- 成本：显著降低

---

## 🚀 下一步：Integration Agent

```yaml
# 未来实现
on:
  pull_request:
    types: [opened, synchronize]

检测 INTEGRATION_AGENT_ID
  ↓ 不存在？创建新Agent
  ↓ 存在？follow-up
自动review PR
  ↓
评论建议和问题
  ↓
记录"为什么这样改"
```

**Integration Agent的记忆：**
- PR #1: 重构了登录逻辑，采用JWT
- PR #2: 数据库迁移到PostgreSQL
- PR #3: （参考PR #1和#2的架构决策）
  → Agent："这个PR应该使用JWT认证，保持一致性"

---

## 📝 最佳实践

### DO ✅
1. 定期review Scanning Agent的输出
2. 发现问题及时reset Agent
3. 在PR评论中清晰描述需求
4. 合理使用 @agent 触发follow-up

### DON'T ❌
1. 不要频繁reset Agent（会丢失记忆）
2. 不要在不同Issue之间期待共享记忆
3. 不要同时手动和自动操作同一Issue
4. 不要删除 agent:xxx 标签（会断开关联）

---

## 🔍 问题排查

### Scanning Agent重复创建Issue？

**原因：** Agent记忆可能出现偏差

**解决：**
1. Reset Scanning Agent
2. 调整 prompt 增加"检查已有Issues"的指令

### Development Agent没有响应？

**原因：** agent:xxx 标签丢失

**解决：**
1. 从Issue历史找到Agent ID
2. 手动添加标签 `agent:bc-xxx`
3. 重新评论 @agent

### 为什么不同Issue的Agent不共享知识？

**设计如此：** 并行开发需要独立上下文，避免干扰。

**解决：** 使用 Integration Agent（未来）做整体review。
