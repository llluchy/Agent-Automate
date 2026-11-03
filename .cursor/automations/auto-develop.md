# AI自动开发Agent指令

## 触发条件
当Issue标签包含 `ai-approved` 时自动触发

## 核心任务
完成Issue中描述的功能开发，并创建可审查的PR。

## 执行流程

### 1. 信息收集
```bash
# 读取Issue内容
- Issue编号：${ISSUE_NUMBER}
- Issue标题：${ISSUE_TITLE}
- 风险等级：检查标签（low-risk/medium-risk/high-risk）
- 需求详情：完整阅读Issue描述
```

### 2. 创建分支
```bash
# 分支命名规则
git checkout -b cursor/issue-${ISSUE_NUMBER}-${描述性名称}-6dcb

# 示例：
# Issue #123: 添加用户登录功能
# 分支名: cursor/issue-123-user-login-6dcb
```

### 3. 开发实现

#### 3.1 理解需求
- 明确验收标准
- 识别相关代码位置
- 规划实现方案

#### 3.2 编写代码
- 遵循项目现有代码风格
- 保持函数简洁、职责单一
- 添加必要的错误处理

#### 3.3 编写测试
根据风险等级决定测试深度：

**低风险**（样式、文档）：
- 基础冒烟测试

**中风险**（新功能）：
- 单元测试：覆盖主要逻辑
- 集成测试：测试与其他模块交互

**高风险**（核心业务、数据处理）：
- 完整单元测试
- 集成测试
- E2E测试
- 边界情况测试
- 错误场景测试

### 4. 自动化测试
```bash
# 运行测试套件
npm test                      # 或 pytest, go test 等
npm run test:integration
npm run lint
npm run type-check

# 记录测试结果
```

### 5. 手动测试（computerUse）

如果是UI相关功能：
```bash
# 1. 启动开发服务器
npm run dev

# 2. 打开浏览器测试
- 访问相关页面
- 执行用户操作
- 截图关键步骤
- 录制演示视频

# 3. 保存成果物到 /cursor/artifacts/
```

### 6. 提交代码
```bash
# 提交规范
git add .
git commit -m "feat(#${ISSUE_NUMBER}): ${简短描述}

- 详细变更说明
- 相关测试
- 风险评估

Closes #${ISSUE_NUMBER}"

# 推送分支
git push -u origin cursor/issue-${ISSUE_NUMBER}-xxx-6dcb
```

### 7. 创建Pull Request

使用 `ManagePullRequest` 工具：

```javascript
{
  action: "create_pr",
  branch_name: "cursor/issue-123-xxx-6dcb",
  base_branch: "main",
  draft: true,  // 始终创建Draft PR
  title: "[风险等级] ${Issue标题}",
  body: `
## 关联Issue
Closes #${ISSUE_NUMBER}

## 📋 变更说明
${详细描述做了什么改动}

## ✅ 测试
- [x] 单元测试通过 (${通过数}/${总数})
- [x] 集成测试通过
- [x] Lint检查通过
- [x] 类型检查通过
${如果有手动测试}
- [x] 手动测试完成

## 🎬 测试成果物
${如果有截图}
<img src="/cursor/artifacts/screenshots/before.png" alt="改动前" width="400"/>
<img src="/cursor/artifacts/screenshots/after.png" alt="改动后" width="400"/>

${如果有视频}
<video src="/cursor/artifacts/demo.mp4" controls width="600"></video>

## ⚠️ 风险评估
- **风险等级**：${低/中/高}
- **影响范围**：${描述影响的模块}
- **回滚方案**：${如果出问题如何回滚}
- **需要人工测试**：${是/否}

${如果是高风险}
## 🚨 高风险变更 - 必须人工深度测试
- [ ] 人工测试步骤1：...
- [ ] 人工测试步骤2：...
- [ ] 数据备份已完成
- [ ] 回滚脚本已准备

## 📊 代码统计
- 新增文件：${数量}
- 修改文件：${数量}
- 新增代码行：${数量}
- 删除代码行：${数量}
- 测试覆盖率：${百分比}

## 🔗 相关链接
- Issue: #${ISSUE_NUMBER}
- CI运行：${CI链接}
- 部署预览：${如果有}

---
**此PR由AI自动创建，等待人工审核**
`
}
```

### 8. 后续处理

创建PR后：
```bash
# 添加标签
根据风险等级添加：
- high-risk → needs-manual-test
- medium-risk → needs-review
- low-risk → ready-for-review

# 在Issue中评论
在原Issue中评论PR链接：
"✅ 开发完成，PR已创建：#${PR_NUMBER}"
```

## 失败处理

如果测试失败或遇到问题：
```bash
# 1. 记录失败原因
# 2. 尝试修复（最多3次）
# 3. 如果无法修复，在Issue中评论：

"⚠️ 开发遇到问题，需要人工介入：
- 失败原因：${详细说明}
- 已尝试方案：${说明尝试过什么}
- 建议：${给出建议}

分支：cursor/issue-${ISSUE_NUMBER}-xxx-6dcb（已保留）
"
```

## 质量检查清单

在创建PR前确认：
- [ ] 所有自动化测试通过
- [ ] 代码符合项目规范
- [ ] 没有遗留的console.log/debugger
- [ ] 提交信息清晰
- [ ] PR描述完整
- [ ] 风险评估准确
- [ ] 测试成果物齐全（如果需要）

## 并行开发说明

- 每个Issue对应一个独立的Agent实例
- 各Agent在各自分支工作，互不干扰
- 同时可以有多个PR等待审核
- 人工审核可以并行处理多个PR
