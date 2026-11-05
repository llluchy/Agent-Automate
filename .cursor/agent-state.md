# Agent状态管理方案

## 当前行为
每次workflow触发创建**新Agent**，空上下文，需要重新读取仓库。

## 保持上下文的方案

### 方案A：Issue关联Agent（推荐）
1. 首次`/approve`触发创建Agent
2. 将`agent.id`存入Issue labels: `agent:bc-xxx`
3. 后续评论检测到`agent:xxx`，发送follow-up到同一Agent

### 方案B：使用GitHub Issues作为状态存储
```yaml
# Issue body追加
<!-- AGENT_ID: bc-00000000-0000-0000-0000-000000000001 -->
```

### 方案C：PR关联Agent
Agent创建的PR自动关联agent.id，PR评论继续对话。

## 实现难点
- GitHub Actions是stateless的
- 需要解析Issue/PR内容提取agent.id
- Agent lifecycle管理（何时结束对话）
