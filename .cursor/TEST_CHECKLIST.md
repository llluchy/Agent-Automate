# 🧪 自动化流程测试清单

## 测试日期：____年____月____日

---

## 第1阶段：Issue创建测试 ✅ 已完成

- [x] Issue创建成功
- [x] Issue链接：https://github.com/llluchy/Agent-Automate/issues/1
- [x] Agent可以创建Issue

---

## 第2阶段：Labels创建（手动）

访问：https://github.com/llluchy/Agent-Automate/labels

需要创建的Labels：

- [ ] `ai-proposed` (颜色: #d4c5f9)
  - 描述：AI提议的改进，等待人工审批
  
- [ ] `ai-approved` (颜色: #0e8a16)
  - 描述：已批准，可以开发
  
- [ ] `low-risk` (颜色: #c2e0c6)
  - 描述：低风险变更
  
- [ ] `medium-risk` (颜色: #fbca04)
  - 描述：中风险变更
  
- [ ] `high-risk` (颜色: #d93f0b)
  - 描述：高风险变更

**完成标志**：在仓库Labels页面看到所有5个新标签

---

## 第3阶段：Automation配置

访问：https://cursor.com/settings → Automations

### 配置信息
- [ ] 点击"New Automation"
- [ ] 名称填写：`AI自动开发测试`
- [ ] 选择触发类型：`GitHub Issue`
- [ ] 事件类型：`labeled`
- [ ] 标签过滤：`ai-approved`
- [ ] 仓库选择：`llluchy/Agent-Automate`
- [ ] 复制Agent指令（见上文）
- [ ] 设置超时：15分钟
- [ ] 开启失败通知
- [ ] 开启成功通知
- [ ] 点击"Save"或"Create"

**完成标志**：在Automations列表中看到新建的Automation

---

## 第4阶段：触发测试

### 4.1 添加标签
- [ ] 访问 Issue #1：https://github.com/llluchy/Agent-Automate/issues/1
- [ ] 点击右侧"Labels"
- [ ] 选择 `ai-approved`
- [ ] 可选：添加 `low-risk`
- [ ] 保存

**完成标志**：Issue页面显示标签已添加

### 4.2 观察触发
- [ ] 访问 Cursor Dashboard：https://cursor.com/agents
- [ ] 查看是否有新的Agent运行
- [ ] 点击Agent查看执行日志
- [ ] 记录Agent的bcId：________________

**完成标志**：看到Agent正在运行

---

## 第5阶段：验证结果（等待5-10分钟）

### 5.1 检查分支
- [ ] 访问仓库分支页面：https://github.com/llluchy/Agent-Automate/branches
- [ ] 查找 `cursor/test-automation-1-6dcb` 分支
- [ ] 点击分支查看提交

**预期结果**：
- 新分支存在
- 有一个提交，包含 `test-automation.txt` 文件

### 5.2 检查PR
- [ ] 访问PR页面：https://github.com/llluchy/Agent-Automate/pulls
- [ ] 查找标题包含"[测试] 自动化流程验证"的PR
- [ ] 点击PR查看详情
- [ ] 记录PR编号：#_____

**预期结果**：
- Draft PR存在
- PR描述完整
- 关联了Issue #1
- 文件变更包含 `test-automation.txt`

### 5.3 检查Issue评论
- [ ] 返回 Issue #1
- [ ] 查看评论区
- [ ] 查找Agent的评论

**预期结果**：
- 有Agent的成功评论
- 评论包含分支名和PR编号

---

## 第6阶段：人工审核（模拟真实流程）

### 6.1 审核PR
- [ ] 打开创建的PR
- [ ] 点击"Files changed"标签
- [ ] 查看 `test-automation.txt` 文件内容
- [ ] 检查内容是否正确

### 6.2 决策
选择以下操作之一：

**选项A：合并（验证完整流程）**
- [ ] 点击"Ready for review"（取消Draft状态）
- [ ] 点击"Merge pull request"
- [ ] 选择"Squash and merge"
- [ ] 确认合并

**选项B：关闭（仅测试，不合并）**
- [ ] 点击"Close pull request"
- [ ] 添加评论说明这是测试
- [ ] 可选：删除测试分支

---

## 测试结果总结

### ✅ 成功标准（全部满足则测试通过）

- [ ] Issue创建成功
- [ ] Automation成功触发
- [ ] Agent成功运行（无错误）
- [ ] 创建了正确的分支
- [ ] 提交了测试文件
- [ ] 创建了Draft PR
- [ ] PR内容正确
- [ ] Issue有Agent评论

**如果全部打勾，恭喜！🎉 自动化流程完全正常！**

### ❌ 失败情况记录

如果测试失败，记录以下信息：

**失败阶段**：__________________________

**错误信息**：
```
（粘贴错误日志）
```

**可能原因**：
- [ ] Automation配置错误
- [ ] 仓库权限不足
- [ ] Agent指令有误
- [ ] 网络问题
- [ ] 其他：__________________________

**解决方案**：
（记录如何解决的）

---

## 下一步行动

### 如果测试成功 ✅
- [ ] 删除测试Issue和PR（或保留作为示例）
- [ ] 配置完整的"需求扫描"Automation
- [ ] 配置完整的"自动开发"Automation
- [ ] 开始实际使用

### 如果测试失败 ❌
- [ ] 查看错误日志
- [ ] 检查配置
- [ ] 调整并重试
- [ ] 必要时寻求帮助

---

## 测试心得笔记

（记录测试过程中的发现和想法）

---

## 重要链接

- 仓库：https://github.com/llluchy/Agent-Automate
- Issue #1：https://github.com/llluchy/Agent-Automate/issues/1
- Cursor Dashboard：https://cursor.com/agents
- Automations设置：https://cursor.com/settings

---

**测试完成时间**：____年____月____日 ____:____

**测试结果**：□ 成功  □ 失败  □ 部分成功

**签名**：____________________
