# 触发器测试 - 最小化验证

> 这是一个最简单的Automation测试，用于验证触发器是否工作。
> 类似于编程中的"console.log"，执行后立即可见。

## 任务目标

验证Cursor Automation能否被GitHub事件正确触发。

## 触发方式

可以通过以下任一方式触发：
- Issue评论（推荐）
- 标签变更
- Issue创建

## 执行动作

在触发的Issue下回复一条评论，包含：
- ✅ 触发成功标志
- 触发时间
- Issue信息
- Agent运行状态

这样就像console.log一样，立即可见，无需查看日志。

---

## Agent指令（复制到Automation配置中）

```bash
#!/bin/bash
set -e

echo "=========================================="
echo "Automation触发器测试开始"
echo "=========================================="

# 1. 获取Issue编号
# 从GitHub事件或环境变量中获取
if [ -n "$GITHUB_EVENT_ISSUE_NUMBER" ]; then
    ISSUE_NUMBER="$GITHUB_EVENT_ISSUE_NUMBER"
elif [ -n "$ISSUE_NUMBER" ]; then
    ISSUE_NUMBER="$ISSUE_NUMBER"
else
    # 如果没有环境变量，尝试从事件JSON解析
    ISSUE_NUMBER=$(echo "${GITHUB_EVENT:-{}}" | jq -r '.issue.number // 1')
fi

echo "📋 Issue编号: #${ISSUE_NUMBER}"

# 2. 生成评论内容
COMMENT_BODY="✅ **Automation触发成功！**

## 📊 触发信息
- ⏰ 触发时间: \`$(date '+%Y-%m-%d %H:%M:%S %Z')\`
- 🎫 Issue编号: #${ISSUE_NUMBER}
- 🤖 Agent状态: 正常运行
- 🔧 测试类型: 最小化触发器测试

## 🎉 测试结果
如果你看到这条评论，说明：
- ✅ Automation配置正确
- ✅ GitHub webhook正常
- ✅ 触发条件工作正常
- ✅ Agent可以执行命令
- ✅ 可以与GitHub交互

## 📝 下一步
现在可以配置完整的开发Automation了！

---
*此评论由Cursor Automation自动生成 · 测试时间: $(date '+%Y-%m-%d %H:%M:%S')*"

echo "💬 准备发表评论..."

# 3. 发表评论到Issue
gh issue comment "${ISSUE_NUMBER}" \
    --repo llluchy/Agent-Automate \
    --body "${COMMENT_BODY}"

if [ $? -eq 0 ]; then
    echo "✅ 成功：评论已发表到Issue #${ISSUE_NUMBER}"
    echo ""
    echo "🎉 测试完成！"
    echo "访问 https://github.com/llluchy/Agent-Automate/issues/${ISSUE_NUMBER} 查看评论"
else
    echo "❌ 错误：评论发表失败"
    exit 1
fi

echo "=========================================="
echo "测试成功完成"
echo "=========================================="
```

---

## 配置步骤

### 1. 创建Automation

访问：https://cursor.com/settings → Automations → New Automation

### 2. 基本信息
```
名称: 触发器测试
描述: 最小化测试，验证Automation是否能被触发
```

### 3. 触发条件

**推荐：Issue评论触发**
```
类型: Issue comment
仓库: llluchy/Agent-Automate
过滤: 无（或填写：包含"测试"）
```

**或者：标签变更触发**
```
类型: Label change
仓库: llluchy/Agent-Automate
标签: test-trigger
```

### 4. Agent指令

复制上面的完整bash脚本。

### 5. 高级设置
```
超时: 5分钟
并发: 关闭
失败通知: 开启
成功通知: 开启
```

### 6. 保存

点击"Create"或"Save"。

---

## 测试执行

### 方法1：评论触发
1. 访问：https://github.com/llluchy/Agent-Automate/issues/1
2. 发表评论："测试Automation触发"
3. 等待30秒-2分钟
4. 刷新页面查看Agent的回复

### 方法2：标签触发
1. 创建标签`test-trigger`（如果还没有）
2. 给Issue #1添加此标签
3. 等待30秒-2分钟
4. 刷新页面查看Agent的回复

---

## 成功标准

✅ **测试成功的标志**：
- Issue下出现Agent的评论
- 评论内容包含"Automation触发成功"
- 显示正确的触发时间和Issue编号
- Cursor Dashboard显示Agent运行成功

❌ **测试失败的标志**：
- 2分钟后仍无评论
- Cursor Dashboard无Agent运行记录
- Dashboard显示错误

---

## 常见问题

### Q: 等了5分钟还是没反应？
A: 检查：
1. Automation是否启用（toggle开关）
2. 仓库名称是否正确
3. 触发条件是否匹配
4. GitHub webhook是否配置（settings/hooks）

### Q: Agent运行了但评论失败？
A: 可能是：
1. gh CLI认证问题
2. 权限不足
3. 查看Agent日志获取详细错误

### Q: 如何查看详细日志？
A: 
1. 访问：https://cursor.com/agents
2. 点击对应的Agent运行记录
3. 查看完整执行日志

---

## 优势

这个测试方案的优点：
- 🚀 快速：几秒钟执行完成
- 👁️ 可见：评论直接显示在Issue中
- 🔒 安全：不修改代码，不创建分支
- ✅ 清晰：一眼就能看出是否成功
- 🧹 干净：只添加一条评论，无其他影响

---

## 测试成功后

当你看到Agent的成功评论后：

1. ✅ 确认Automation基础设施正常
2. ✅ 可以继续配置完整的开发Automation
3. ✅ 可以删除测试评论（可选）
4. ✅ 可以删除测试标签（可选）
5. ✅ 可以禁用或删除此测试Automation

---

## 下一步

测试通过后，继续：
1. 创建需要的Labels（ai-proposed, ai-approved等）
2. 配置完整的"AI自动开发"Automation
3. 开始真实使用

祝测试顺利！🎉
