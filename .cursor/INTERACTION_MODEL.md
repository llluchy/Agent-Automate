# Agent交互模式

## 🎯 核心理念：自然对话

每个Issue = 一个专属Agent = 完整的开发生命周期

```
Issue创建/首次评论
    ↓
自动创建Agent并关联
    ↓
多轮对话讨论需求
    ↓
"开始开发"
    ↓
Agent创建PR
    ↓
继续在Issue中对话优化
```

---

## 📝 使用方式

### 1️⃣ 创建Issue

**任意方式创建Issue都会自动触发：**

```markdown
标题: 添加用户登录功能

内容:
需要实现：
1. 用户名密码登录
2. 记住登录状态
3. 登出功能
```

**Agent自动：**
- ✅ 创建专属Agent
- ✅ 添加 `agent:bc-xxx` 标签
- ✅ 回复初始消息

---

### 2️⃣ 讨论阶段（多轮对话）

**在Issue评论即可，无需任何标记：**

```
你: 登录应该用JWT还是Session？

Agent: 建议使用JWT，因为：
1. 项目已有token机制
2. 支持移动端
3. 无状态更易扩展
...

你: 那安全性如何保证？

Agent: 可以这样设计...
1. ...
2. ...

你: 好的，开始开发吧
```

**Agent响应：**
- 🚀 每条评论自动触发Agent
- 💬 Agent直接回复到Issue
- 🧠 保持完整对话上下文

---

### 3️⃣ 开发阶段

**明确告诉Agent开始：**

```
你: 开始开发

或

你: 按照我们讨论的方案，现在可以实现了

或

你: 帮我实现这个功能
```

**Agent自动：**
1. 创建开发分支 `cursor/issue-123-xxx-6dcb`
2. 实现功能
3. 运行测试
4. 创建Draft PR
5. 在Issue回复PR链接

---

### 4️⃣ 优化阶段

**PR创建后，继续在Issue评论：**

```
你: 测试发现登录超时设置太短

Agent: 好的，我调整为30分钟
（自动更新PR）

你: 再加个记住登录的选项

Agent: 已添加"记住我"功能
（自动更新PR）
```

**Agent响应：**
- 🔄 自动更新PR
- 📝 保持Issue和PR同步
- ✅ 持续优化直到满意

---

### 5️⃣ 完成

**确认后合并：**

```
你: 看起来不错，合并吧

Agent: 好的，请review并合并PR
```

**你：**
- Review PR代码
- 合并到main
- Issue自动关闭

---

## 🔥 特殊场景

### 场景1：AI扫描创建的Issue

```
AI每日扫描 → 创建Issue
    ↓
（此时还没有Agent）
    ↓
你评论: "这个需求有必要，继续分析"
    ↓
自动创建Agent开始对话
```

### 场景2：人工创建Issue

```
你创建Issue
    ↓
你评论或AI评论
    ↓
自动创建Agent
```

### 场景3：多个Issue并行

```
Issue #1 → Agent A → 开发登录功能
Issue #2 → Agent B → 优化数据库
Issue #3 → Agent C → 修复Bug

三个Agent独立工作，互不干扰
```

### 场景4：Issue中途讨论

```
PR已创建
    ↓
Issue中评论: "需要改个小地方"
    ↓
Agent继续修改（同一Agent，有上下文）
    ↓
自动更新PR
```

---

## 💡 最佳实践

### ✅ DO

1. **清晰描述需求**
   ```
   标题: 添加搜索功能
   内容: 
   - 支持全文搜索
   - 实时提示
   - 分页显示
   ```

2. **充分讨论再开发**
   ```
   先讨论：设计方案、技术选型
   再开发：明确说"开始开发"
   ```

3. **持续反馈**
   ```
   测试PR → 发现问题 → Issue评论反馈
   Agent会在同一上下文中修改
   ```

4. **利用Agent的记忆**
   ```
   Agent记得：
   - Issue的完整讨论
   - 你的偏好和要求
   - 项目的代码风格
   ```

### ❌ DON'T

1. **不要删除 agent:xxx 标签**
   - 会断开Agent关联
   - 后续评论无法触发

2. **不要在多个Issue重复讨论**
   - 每个Agent只知道自己Issue的内容
   - 应在一个Issue中完整讨论

3. **不要期待Agent知道Issue外的讨论**
   - Agent不会主动查看其他Issue
   - 需要的信息要在当前Issue提供

4. **不要在Issue和PR同时评论**
   - 统一在Issue评论
   - Agent会自动同步到PR

---

## 🔍 对比旧模式

### 旧模式（已废弃）

```
❌ 必须评论 /approve 触发
❌ 立即开始开发，无法讨论
❌ PR后需要 @agent 才能继续对话
```

### 新模式（推荐）

```
✅ 任意评论自动触发
✅ 先讨论后开发，自然流程
✅ Issue和PR统一在Issue对话
```

---

## 🛠️ 技术实现

### Agent创建时机

```yaml
触发条件:
  - Issue首次评论
  - Issue被创建

检查:
  - Issue是否已有 agent:xxx 标签？

动作:
  - 没有 → 创建Agent + 添加标签
  - 有 → follow-up到已有Agent
```

### 评论响应

```yaml
每次Issue评论:
  - 自动发送到Agent
  - Agent回复显示在Issue中
  - 添加🚀 reaction表示已处理
```

---

## 📊 Agent状态追踪

### 查看Agent信息

```bash
# 从Issue标签获取Agent ID
gh issue view 123 --json labels

# 访问Agent Dashboard
https://cursor.com/agents/bc-xxx
```

### 判断Agent状态

| Issue标签 | 含义 |
|----------|------|
| `agent:bc-xxx` | 已关联Agent |
| 无agent标签 | 尚未创建Agent |

---

## 🚀 开始使用

1. **创建Issue**（任意方式）
2. **等待Agent响应**（自动）
3. **开始对话**（随意评论）
4. **确认需求**（充分讨论）
5. **开始开发**（明确指示）
6. **持续优化**（继续评论）
7. **Review合并**（完成）

就是这么简单！🎉
