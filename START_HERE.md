# 🚀 从这里开始 - 最小化测试

> **好消息**：Issue创建功能已测试通过！✅

---

## ✅ 已完成

- [x] **Issue创建测试** - 成功！
  - Issue #1：https://github.com/llluchy/Agent-Automate/issues/1
  - Agent可以通过gh CLI创建Issues

---

## 🎯 接下来3步（30分钟）

### 📝 第1步：创建Labels（5分钟）

访问：https://github.com/llluchy/Agent-Automate/labels

点击"New label"按钮，创建以下5个标签：

```
1. ai-proposed
   颜色: #d4c5f9 (淡紫色)
   描述: AI提议的改进，等待人工审批

2. ai-approved  
   颜色: #0e8a16 (绿色)
   描述: 已批准，可以开发

3. low-risk
   颜色: #c2e0c6 (淡绿色)
   描述: 低风险变更

4. medium-risk
   颜色: #fbca04 (黄色)
   描述: 中风险变更

5. high-risk
   颜色: #d93f0b (红色)
   描述: 高风险变更
```

**快速创建链接**（复制到浏览器）：
```
https://github.com/llluchy/Agent-Automate/labels/new?name=ai-proposed&color=d4c5f9
https://github.com/llluchy/Agent-Automate/labels/new?name=ai-approved&color=0e8a16
https://github.com/llluchy/Agent-Automate/labels/new?name=low-risk&color=c2e0c6
https://github.com/llluchy/Agent-Automate/labels/new?name=medium-risk&color=fbca04
https://github.com/llluchy/Agent-Automate/labels/new?name=high-risk&color=d93f0b
```

---

### ⚙️ 第2步：配置Automation（10分钟）

访问：https://cursor.com/settings → Automations → New Automation

#### 基本信息
```
名称: AI自动开发测试
描述: 测试自动化流程
```

#### 触发条件
```
类型: GitHub Issue
事件: labeled (标签变更)
仓库: llluchy/Agent-Automate
标签过滤: ai-approved
```

#### Agent指令
复制以下内容到指令框（**完整复制，包括代码块**）：

```markdown
# 测试Agent - 最小化验证

验证自动化流程是否正常工作。

## 执行步骤

### 1. 创建测试分支
```bash
ISSUE_NUMBER=$(echo $GITHUB_EVENT | jq -r '.issue.number')
ISSUE_TITLE=$(echo $GITHUB_EVENT | jq -r '.issue.title')

git checkout -b cursor/test-automation-${ISSUE_NUMBER}-6dcb
```

### 2. 创建测试文件
```bash
cat > test-automation.txt << EOF
# 自动化测试验证成功！

## Issue信息
- Issue编号: ${ISSUE_NUMBER}
- Issue标题: ${ISSUE_TITLE}
- 测试时间: $(date '+%Y-%m-%d %H:%M:%S')

## 验证内容
✅ Automation成功触发
✅ Agent成功启动
✅ 分支创建成功
✅ 文件创建成功

如果你能看到这个文件，说明自动化流程完全正常！🎉
EOF
```

### 3. 提交代码
```bash
git add test-automation.txt
git commit -m "test: 验证自动化流程 #${ISSUE_NUMBER}"
git push -u origin cursor/test-automation-${ISSUE_NUMBER}-6dcb
```

### 4. 创建PR
使用ManagePullRequest工具：
- action: create_pr
- branch_name: cursor/test-automation-${ISSUE_NUMBER}-6dcb
- draft: true
- title: "[测试] 自动化流程验证 #${ISSUE_NUMBER}"
- body: 包含测试结果和验证信息
```

#### 高级设置
```
超时: 15分钟
失败通知: ✅ 开启
成功通知: ✅ 开启
```

点击"Create"或"Save"保存。

---

### 🧪 第3步：触发测试（10分钟）

#### 3.1 添加标签触发
1. 访问：https://github.com/llluchy/Agent-Automate/issues/1
2. 点击右侧"Labels"
3. 选择 `ai-approved`
4. 保存

#### 3.2 观察执行
1. 访问：https://cursor.com/agents
2. 查看新启动的Agent
3. 点击查看执行日志

#### 3.3 验证结果（5分钟后）

**检查清单**：
- [ ] Cursor Dashboard显示Agent运行
- [ ] GitHub出现新分支：`cursor/test-automation-1-6dcb`
- [ ] GitHub出现新PR
- [ ] PR包含 `test-automation.txt` 文件
- [ ] Issue #1有Agent的评论

**全部勾选 = 测试成功！🎉**

---

## 📊 预期结果

### 如果成功 ✅
你会看到：
1. **Cursor Dashboard**：Agent显示"Completed"或"Success"
2. **GitHub Branches**：出现 `cursor/test-automation-1-6dcb`
3. **GitHub Pull Requests**：新的Draft PR
4. **Issue #1**：Agent的成功评论

### 如果失败 ❌
检查：
1. Automation是否正确配置
2. 标签名称是否完全匹配 `ai-approved`
3. 仓库名称是否正确
4. Agent日志中的错误信息

---

## 🎓 测试通过后

### 下一步：
1. ✅ 删除或合并测试PR
2. ✅ 配置完整的"需求扫描"Automation
3. ✅ 配置完整的"自动开发"Automation  
4. ✅ 开始真实使用！

### 完整文档：
- 📖 **总体方案**：`README_AI_WORKFLOW.md`
- 📚 **详细配置**：`.cursor/AUTOMATIONS_SETUP.md`
- ⚡ **快速指南**：`.cursor/QUICK_START.md`
- ✅ **测试清单**：`.cursor/TEST_CHECKLIST.md`

---

## 💡 提示

### Agent指令环境变量
- `$GITHUB_EVENT`：完整的GitHub事件JSON
- `$ISSUE_NUMBER`：Issue编号（如果有）
- `$ISSUE_TITLE`：Issue标题

### 调试技巧
- 查看Cursor Dashboard的完整日志
- 使用 `echo` 输出调试信息
- 先本地测试命令，再放入Agent指令

### 常见问题
**Q: Automation没触发？**
- 检查标签名称是否完全匹配
- 确认Automation已启用（toggle开关）
- 查看是否有webhook配置问题

**Q: Agent运行失败？**
- 查看Dashboard日志
- 检查git命令是否正确
- 确认分支命名符合规范

---

## 📞 需要帮助？

- 📋 **详细测试清单**：`.cursor/TEST_CHECKLIST.md`
- 📚 **完整文档**：`.cursor/AUTOMATIONS_SETUP.md`
- 🔗 **测试Issue**：https://github.com/llluchy/Agent-Automate/issues/1

---

**现在就开始第1步吧！** 创建5个Labels只需要5分钟 ⏱️
