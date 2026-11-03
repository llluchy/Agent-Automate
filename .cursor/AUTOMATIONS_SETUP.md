# Cursor Automations 配置指南

## 概述

使用Cursor Automations实现AI自主开发流程：
1. **Automation 1**: 定期扫描需求，创建Issue
2. **Automation 2**: Issue批准后自动开发，创建PR
3. **人工介入点**: Issue审批、PR审核、生产部署

---

## 配置步骤

### 1️⃣ 配置Automation 1: 需求扫描

访问：https://cursor.com/settings → Automations → New Automation

#### 基本信息
- **名称**: `AI需求扫描器`
- **描述**: `每日扫描代码库，自动发现潜在改进点并创建Issue`

#### 触发条件（Trigger）
选择以下任一：

**选项A：定时触发（推荐）**
- 触发类型: `Schedule (定时)`
- 时间: `每天 09:00` （你上班/主业开始的时候）
- 时区: `Asia/Shanghai (UTC+8)`

**选项B：手动触发**
- 触发类型: `Manual (手动)`
- 你想扫描时手动点击运行

#### Agent配置
- **Environment**: 选择你的开发环境
- **Agent指令**: 复制 `.cursor/automations/scan-requirements.md` 的内容

#### 高级设置
- **模型**: 默认（或选择更快的模型用于扫描）
- **超时**: 30分钟
- **失败通知**: ✅ 开启

---

### 2️⃣ 配置Automation 2: 自动开发（关键）

#### 基本信息
- **名称**: `AI自动开发`
- **描述**: `Issue批准后自动开发并创建PR`

#### 触发条件（Trigger）
**触发类型**: `GitHub Issue` 事件

配置选项：
```yaml
事件类型: labeled (标签变更)
标签过滤: ai-approved
仓库: {你的仓库}
```

**或者使用评论触发**：
```yaml
事件类型: issue_comment
评论内容包含: /approve 或 /develop
```

#### Agent配置
- **Environment**: 选择你的开发环境
- **Agent指令**: 复制 `.cursor/automations/auto-develop.md` 的内容

#### 并行配置（重要⭐）
- **并发执行**: ✅ 开启
- **最大并行数**: 5（或根据你的需求）

这样多个Issue可以同时开发，不会排队！

#### 高级设置
- **模型**: 默认
- **超时**: 2小时（复杂任务可能需要更长）
- **失败通知**: ✅ 开启
- **成功通知**: ✅ 开启（可选）

---

### 3️⃣ 配置Issue模板

创建 `.github/ISSUE_TEMPLATE/ai-proposed.md`：

```markdown
---
name: AI提议的改进
about: 由AI自动创建的功能/改进建议
labels: ai-proposed
---

## 📋 需求来源
- [ ] 代码TODO
- [ ] 测试覆盖率
- [ ] 代码质量
- [ ] 依赖更新
- [ ] 其他

## 📝 描述


## 🎯 预期收益


## ⚠️ 风险评估
- 风险等级: 低/中/高
- 影响范围: 
- 测试难度: 简单/中等/复杂

## 💻 相关代码


## 🔧 建议实现方案


## ⏱️ 工作量估算
- 开发: X小时
- 测试: X小时

---
**此Issue由AI自动生成，等待人工审批**

审批方式：
1. 修改标签：`ai-proposed` → `ai-approved`
2. 或评论：`/approve`
```

---

### 4️⃣ 配置PR模板

创建 `.github/PULL_REQUEST_TEMPLATE.md`：

```markdown
## 关联Issue
Closes #

## 📋 变更说明


## ✅ 测试
- [ ] 单元测试通过
- [ ] 集成测试通过
- [ ] Lint检查通过
- [ ] 类型检查通过
- [ ] 手动测试完成（如需要）

## 🎬 测试成果物
<!-- Agent会自动填充截图/视频 -->


## ⚠️ 风险评估
- **风险等级**: 低/中/高
- **影响范围**: 
- **回滚方案**: 
- **需要人工测试**: 是/否

## 📊 代码统计
- 新增文件: 
- 修改文件: 
- 新增代码行: 
- 删除代码行: 

---
**此PR由AI自动创建，等待人工审核**
```

---

### 5️⃣ 配置GitHub Labels

创建以下标签（在GitHub仓库设置中）：

```bash
# 需求状态
ai-proposed      # 灰色  - AI提议，等待审批
ai-approved      # 绿色  - 已批准，可以开发

# 风险等级
low-risk         # 绿色  - 低风险
medium-risk      # 黄色  - 中风险  
high-risk        # 红色  - 高风险

# PR状态
needs-manual-test  # 橙色  - 需要人工深度测试
needs-review       # 蓝色  - 需要代码审查
ready-for-review   # 绿色  - 可以审查了
```

---

## 完整工作流程示例

### 🌅 白天（你在主业时）

#### 09:00 - Automation 1 自动运行
```
✅ 扫描代码库
✅ 发现5个改进点
✅ 创建5个Issues（标签: ai-proposed）
📧 发送通知：今天发现5个改进建议
```

#### 09:30 - 你快速审批（5分钟）
在手机/电脑上快速浏览Issues：
```
Issue #101: [AI提议] 补充用户登录测试 → ✅ 批准（改标签ai-approved）
Issue #102: [AI提议] 重构数据库连接池  → ✅ 批准
Issue #103: [AI提议] 更新过期依赖     → ✅ 批准
Issue #104: [AI提议] 添加性能监控     → ❌ 拒绝（关闭）
Issue #105: [AI提议] 重写用户模块     → 🤔 稍后再看
```

#### 09:31 - Automation 2 自动触发（3个并行Agent）
```
Agent A: 开发 Issue #101 → 分支 cursor/issue-101-login-test-6dcb
Agent B: 开发 Issue #102 → 分支 cursor/issue-102-db-pool-6dcb  
Agent C: 开发 Issue #103 → 分支 cursor/issue-103-deps-update-6dcb

三个Agent同时工作，互不干扰！
```

#### 10:00-17:00 - AI持续工作
```
✅ Agent A完成：创建PR #201 (Draft)
✅ Agent B完成：创建PR #202 (Draft)
✅ Agent C完成：创建PR #203 (Draft)

📧 通知：3个PR已创建，等待审核
```

### 🌙 晚上（你回家开始副业）

#### 19:00 - 你开始审核（30-45分钟）

**看Dashboard**：
```
今日AI工作总结：
- 扫描需求：5个
- 开发完成：3个
- PR创建：3个
- 等待审核：3个
```

**审核PR #201（低风险）**：
```bash
# 查看变更
✅ Diff很清晰：+120行测试代码
✅ 所有测试通过
✅ 没有业务逻辑变更

# 快速决策
👍 Approve → Merge
```

**审核PR #202（中风险）**：
```bash
# 查看变更
✅ Diff合理：重构连接池逻辑
✅ 测试通过
🤔 看起来不错，但需要简单验证

# 本地拉取分支快速测试（5分钟）
git fetch origin cursor/issue-102-db-pool-6dcb
git checkout cursor/issue-102-db-pool-6dcb
npm test
npm run dev  # 跑一下看看

✅ 验证通过
👍 Approve → Merge
```

**审核PR #203（高风险 - 依赖更新）**：
```bash
# 查看变更
⚠️ 多个依赖大版本升级
✅ Agent说测试都过了
🚨 但这个需要更谨慎

# 决策：
1. Mark as ready for review（不立即合并）
2. 先部署到Staging环境
3. 观察1-2天
4. 没问题再合并到main
```

#### 19:45 - 审核完成
```
今晚处理：
✅ 合并2个PR
🔄 1个PR待观察
📈 你的时间：45分钟审核 vs 如果自己写需要6-8小时

效率提升：~8-10倍！
```

---

## 你的每日工作流

```
白天（主业）：
09:00  ☕️ 喝咖啡时：快速审批AI生成的Issues（5分钟）
       🤖 AI自动开始开发（你不管了）

晚上（副业）：
19:00  📋 查看Dashboard：今天完成了什么
19:10  👀 审核PR：看代码、测试报告、成果物
19:30  ✅ 低风险直接合并
19:45  🧪 中高风险简单测试后决策
20:00  ✨ 完成！省下的时间可以：
       - 思考架构
       - 做更有挑战性的工作
       - 或者休息 😊
```

---

## Cursor能做到的 ✅

| 功能 | 支持程度 | 说明 |
|-----|---------|------|
| **定时触发** | ✅ 完全支持 | Schedule trigger |
| **Issue触发** | ✅ 完全支持 | GitHub webhook集成 |
| **并行开发** | ✅ 完全支持 | 多Agent同时运行 |
| **独立分支** | ✅ 完全支持 | 每个Agent独立分支 |
| **自动测试** | ✅ 完全支持 | 运行测试套件 |
| **手动测试** | ✅ 完全支持 | computerUse |
| **截图/录屏** | ✅ 完全支持 | 自动生成成果物 |
| **创建PR** | ✅ 完全支持 | ManagePullRequest工具 |
| **Draft PR** | ✅ 完全支持 | 防止误合并 |
| **失败通知** | ✅ 完全支持 | 自动通知 |

## Cursor做不到的 ❌（需要你配置）

| 功能 | 需要 | 说明 |
|-----|------|------|
| **CI/CD** | GitHub Actions | 自动化测试和部署 |
| **代码审查** | 人工 | 最终决策必须是人 |
| **生产部署** | 人工批准 | 安全考虑 |
| **监控告警** | Sentry等 | 生产环境监控 |

---

## 下一步行动

1. ✅ 在Cursor设置中配置这两个Automations
2. ✅ 配置GitHub Issue和PR模板
3. ✅ 添加必要的Labels
4. ✅ 测试流程：
   - 手动创建一个测试Issue
   - 标记为 ai-approved
   - 观察Agent是否自动开始工作
   - 检查PR是否正确创建
5. ✅ 优化调整：
   - 根据实际效果调整Agent指令
   - 优化风险分级
   - 完善测试策略

---

## 常见问题

### Q1: 会不会同时触发太多Agent，资源不够？
A: 在Automation配置中设置"最大并行数"，比如5个。超过的会排队。

### Q2: Agent开发失败了怎么办？
A: Agent会在Issue中评论失败原因，你可以决定：
- 让它重试
- 人工接手
- 关闭Issue

### Q3: 如何避免AI创建重复的Issue？
A: 在扫描Agent指令中添加检查逻辑：
```bash
gh issue list --label ai-proposed --state open
# 检查是否已有类似Issue
```

### Q4: 可以让AI直接合并低风险PR吗？
A: 技术上可以，但**强烈不建议**。最好保留人工审批环节，哪怕只是快速看一眼。

### Q5: 成本如何？
A: Cursor Cloud Agent按使用计费。建议：
- 先小规模测试
- 观察成本
- 逐步扩大自动化范围

---

## 总结

使用Cursor Automations，你可以实现：

✅ **白天**：AI自主工作，你专注主业  
✅ **晚上**：只需审核和决策，效率提升8-10倍  
✅ **并行开发**：多个需求同时推进  
✅ **质量保证**：完整测试 + 人工把关  
✅ **风险可控**：分级管理，高风险严格测试  

这就是**AI辅助开发的最佳实践**：人机协作，各司其职！
