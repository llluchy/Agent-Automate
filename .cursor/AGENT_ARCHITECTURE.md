# Agent架构设计

## 三类Agent的记忆模型

### 🔍 1. Scanning Agent（需求挖掘）

**特征：单例长期Agent**

**记忆需求：**
- 已扫描过的代码区域
- 已创建的Issues列表
- 上次扫描的时间和发现
- 项目的技术栈和架构理解

**生命周期：**
- 首次运行：创建Agent，ID存入 `SCANNING_AGENT_ID`
- 后续运行：检测到ID存在 → follow-up到同一Agent
- 永不销毁：持续积累项目知识

**存储方式：**
```yaml
# GitHub Repository Variables
SCANNING_AGENT_ID=bc-xxx-xxx-xxx
```

---

### 💻 2. Development Agents（开发）

**特征：Issue级别独立Agent**

**记忆需求：**
- 当前Issue的需求描述
- 该功能的设计讨论
- 代码修改历史
- 测试结果和反馈

**生命周期：**
- 创建：`/approve`触发，创建新Agent
- 活跃：Issue开发期间，PR评论触发follow-up
- 结束：PR合并后，Agent归档（不删除，保留历史）

**存储方式：**
```yaml
# Issue Labels
agent:bc-xxx-xxx-xxx
```

**并行性：**
- 多个Issue可同时开发
- 每个Agent独立上下文，互不干扰

---

### 🔀 3. Integration Agent（PR审查与合并）

**特征：单例长期Agent**

**记忆需求：**
- 所有PR的历史记录
- 每个PR为什么这样改
- 架构演进的决策过程
- 代码风格和最佳实践的积累

**生命周期：**
- 首次运行：创建Agent，ID存入 `INTEGRATION_AGENT_ID`
- 后续运行：所有PR review都follow-up到同一Agent
- 永不销毁：作为项目的"技术记忆"

**存储方式：**
```yaml
# GitHub Repository Variables
INTEGRATION_AGENT_ID=bc-xxx-xxx-xxx
```

---

## Agent间的信息传递

```
Scanning Agent (发现问题)
    ↓ 创建Issue
Development Agent #1 (实现功能A)
    ↓ 创建PR #1
        ↓ PR Review请求
Integration Agent (review并建议合并)
    ↓ 记录"为什么这样改"
        ↓ 影响下次review
    ↓ PR #2到来
Integration Agent (参考PR #1的决策)
```

**关键：Integration Agent能看到所有PR历史**

---

## 实现优先级

### Phase 1（当前）✅
- [x] Development Agents（已实现）
- [x] Issue级别独立上下文
- [x] PR评论follow-up

### Phase 2（下一步）🚧
- [ ] Scanning Agent持久化
  - 首次运行检测 `SCANNING_AGENT_ID` 是否存在
  - 不存在：创建Agent并存储ID
  - 存在：follow-up到已有Agent

### Phase 3（未来）📋
- [ ] Integration Agent
  - PR创建时触发
  - 自动review代码
  - 建议是否合并
  - 检测冲突和架构问题

---

## 技术挑战

### 1. Agent ID存储
**问题：** GitHub Actions是stateless的，如何持久化Agent ID？

**方案A：GitHub Repository Variables**（推荐）
```bash
# 通过gh CLI设置
gh variable set SCANNING_AGENT_ID --body "bc-xxx"
```

**方案B：存储在仓库文件**
```json
// .cursor/agents.json
{
  "scanning_agent_id": "bc-xxx",
  "integration_agent_id": "bc-yyy"
}
```
缺点：需要commit，可能引起冲突

**方案C：GitHub Gist**
优点：不污染仓库
缺点：需要额外token权限

### 2. Agent生命周期管理
**问题：** 长期Agent何时"重置"？

**建议：**
- Scanning Agent：手动触发reset（创建新Agent）
- Integration Agent：主要版本发布时reset
- 提供workflow手动触发reset

### 3. 记忆污染
**问题：** 长期Agent可能积累错误的"记忆"

**缓解：**
- Prompt中强调"检查最新代码"
- 定期review Agent的假设
- 提供"纠正Agent记忆"的接口

---

## 下一步行动

1. **实现Scanning Agent持久化**
   - 修改 `daily-scan-with-cursor.yml`
   - 检测并复用 `SCANNING_AGENT_ID`

2. **创建Integration Agent workflow**
   - PR创建时触发
   - 自动review并给出建议

3. **Agent管理工具**
   - 列出所有Agent状态
   - 手动reset Agent
   - 查看Agent记忆摘要
