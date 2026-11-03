# 🚀 快速开始：AI自主开发流程

## 5分钟配置清单

### 1️⃣ 准备GitHub仓库

#### 创建Labels（在GitHub仓库设置中）
```bash
# 或使用gh CLI快速创建：
gh label create "ai-proposed" --color "d4c5f9" --description "AI提议，等待审批"
gh label create "ai-approved" --color "0e8a16" --description "已批准，可以开发"
gh label create "low-risk" --color "c2e0c6" --description "低风险变更"
gh label create "medium-risk" --color "fbca04" --description "中风险变更"
gh label create "high-risk" --color "d93f0b" --description "高风险变更"
gh label create "needs-manual-test" --color "ff9800" --description "需要人工深度测试"
```

#### 复制Issue/PR模板
这个仓库已经包含：
- `.cursor/automations/scan-requirements.md` - 需求扫描指令
- `.cursor/automations/auto-develop.md` - 自动开发指令

需要手动创建：
```bash
# 创建.github目录
mkdir -p .github/ISSUE_TEMPLATE

# 从AUTOMATIONS_SETUP.md中复制Issue模板到：
# .github/ISSUE_TEMPLATE/ai-proposed.md

# 复制PR模板到：
# .github/PULL_REQUEST_TEMPLATE.md
```

### 2️⃣ 配置Cursor Automations

访问：https://cursor.com/settings → Automations

#### Automation A: AI需求扫描
```yaml
名称: AI需求扫描器
触发: Schedule - 每天 09:00 (Asia/Shanghai)
指令: 复制 .cursor/automations/scan-requirements.md
并发: 1 (不需要并发)
```

#### Automation B: AI自动开发（⭐核心）
```yaml
名称: AI自动开发
触发: GitHub Issue labeled (标签: ai-approved)
指令: 复制 .cursor/automations/auto-develop.md
并发: 5 (可同时开发5个Issue)
```

### 3️⃣ 测试流程

#### 第一次测试（手动模式）
```bash
# 1. 手动创建一个简单的测试Issue
标题: [AI提议] 测试：在README中添加安装说明
标签: ai-proposed, low-risk
内容: 在README.md文件的开头添加详细的安装步骤

# 2. 审批这个Issue
改标签为: ai-approved

# 3. 观察Automation是否自动触发
- 去Cursor Dashboard查看是否有新的Agent运行
- 查看Agent的执行日志
- 等待PR创建

# 4. 审核PR
- 查看代码变更
- 查看测试结果
- 决定是否合并
```

#### 第二次测试（自动模式）
```bash
# 1. 手动触发或等待定时触发 "AI需求扫描"
- 观察是否自动创建Issue

# 2. 审批创建的Issues
- 选择1-2个批准

# 3. 观察自动开发流程
- 多个Agent并行工作
- 自动创建PRs

# 4. 审核和合并
```

---

## 典型使用场景

### 场景1：修复代码中的TODO

**早上9点 - AI扫描**
```
找到代码中的TODO:
// TODO: 添加输入验证
// TODO: 优化数据库查询
// TODO: 补充单元测试
```

**9:05 - 你审批**（1分钟）
```
✅ 批准：添加输入验证
✅ 批准：补充单元测试
❌ 拒绝：优化查询（暂时不需要）
```

**9:06-11:00 - AI开发**
```
Agent A: 实现输入验证 → PR #101
Agent B: 补充单元测试 → PR #102
```

**晚上7点 - 你审核**（15分钟）
```
审核PR #101: ✅ 合并
审核PR #102: ✅ 合并
```

**结果**：
- 你的时间：16分钟（审批1分钟 + 审核15分钟）
- AI节省你的时间：3-4小时
- 效率提升：**12倍**

---

### 场景2：补充测试覆盖率

**早上9点 - AI扫描**
```
测试覆盖率分析：
- UserService: 45% → 需要补充
- OrderService: 30% → 需要补充
- PaymentService: 80% → 已充足
```

**9:05 - 你审批**
```
✅ 批准：补充UserService测试
✅ 批准：补充OrderService测试
```

**9:06-12:00 - AI开发**
```
Agent A: 编写UserService测试 → PR #103
Agent B: 编写OrderService测试 → PR #104
```

**晚上7点 - 你审核**
```
✅ 查看测试用例是否覆盖关键场景
✅ 运行测试确认通过
✅ 合并
```

---

### 场景3：依赖更新（高风险）

**早上9点 - AI扫描**
```
发现过期依赖：
- react: 17.0.2 → 18.2.0 (大版本更新)
- lodash: 4.17.20 → 4.17.21 (安全补丁)
```

**9:05 - 你审批**
```
✅ 批准：更新lodash (安全补丁，低风险)
✅ 批准：更新react (大版本，高风险)
```

**AI开发 + 你的不同处理**
```
PR #105 (lodash更新，低风险):
- 晚上审核 → 测试通过 → 直接合并

PR #106 (react更新，高风险):
- 晚上审核 → 测试通过 → Mark as ready
- 部署到Staging
- 观察2天
- 确认无问题后合并到main
```

---

## 风险分级处理策略

### 🟢 低风险（可快速审核）
- 文档更新
- 样式调整
- 注释优化
- 小的重构
- 安全补丁

**你的时间**：5分钟/PR

### 🟡 中风险（需要验证）
- 新功能开发
- Bug修复
- 测试补充
- 配置变更

**你的时间**：15-20分钟/PR

### 🔴 高风险（必须深度测试）
- 核心业务逻辑
- 数据库变更
- 大版本升级
- 安全相关

**你的时间**：30-60分钟/PR + 持续观察

---

## 成功指标

### 第一周目标
- [ ] 配置完成2个Automations
- [ ] 成功运行1次完整流程
- [ ] 合并第1个AI生成的PR

### 第一个月目标
- [ ] AI每天生成2-3个Issues
- [ ] 你每天审批通过1-2个
- [ ] 每周合并5-10个PRs
- [ ] 你的开发时间减少50%

### 三个月目标
- [ ] 建立稳定的自动化流程
- [ ] AI处理70%的简单任务
- [ ] 你专注于架构和复杂问题
- [ ] 开发速度提升5-10倍

---

## 常见初期问题

### Q: 第一次触发Automation没反应？
```bash
检查清单：
1. Automation是否已启用（toggle按钮打开）
2. GitHub webhook是否配置正确
3. 查看Cursor Dashboard是否有错误日志
4. 检查仓库权限（Agent需要push权限）
```

### Q: Agent创建的PR质量不好？
```bash
解决方案：
1. 优化Agent指令（在.cursor/automations/中修改）
2. 添加更详细的要求和示例
3. 设置更严格的测试要求
4. 提供项目特定的代码规范
```

### Q: 多个Agent同时工作会冲突吗？
```bash
不会冲突，因为：
1. 每个Agent独立分支
2. 各自的PR
3. 你分别审核和合并
4. Git会处理合并冲突（如果有）
```

---

## 下一步优化

当基础流程稳定后，可以考虑：

### 📈 扩展自动化范围
- 自动生成变更日志
- 自动更新版本号
- 自动发布Release notes

### 🧪 提升测试质量
- 添加E2E测试
- 视觉回归测试
- 性能基准测试

### 🚀 优化部署流程
- 自动部署到Staging
- A/B测试
- 灰度发布

### 📊 数据分析
- 统计AI节省的时间
- 分析最常见的需求类型
- 优化Agent指令

---

## 需要帮助？

如果遇到问题：
1. 查看Cursor Dashboard的Agent日志
2. 检查GitHub Actions/webhooks状态
3. 阅读 `AUTOMATIONS_SETUP.md` 详细文档

---

## 开始吧！🎉

现在你已经有了完整的：
✅ Agent指令文档
✅ 配置指南
✅ 测试流程
✅ 最佳实践

**第一步**：去Cursor设置中配置两个Automations
**第二步**：创建一个测试Issue试试看
**第三步**：享受AI带来的效率提升！

记住：**这是一个渐进的过程**，从简单任务开始，逐步建立信任和优化流程。

祝你的副业开发顺利！🚀
