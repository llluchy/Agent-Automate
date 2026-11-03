# Issue评论触发开发流程

> 基于Cursor Automations的实际限制设计
> Issue触发器只有：Issue comment

## 触发方式

在Issue中评论：`/approve` 或 `/develop`

## Automation配置

```yaml
名称: Issue批准后自动开发
触发: Issue comment
     包含: /approve 或 /develop
仓库: llluchy/Agent-Automate
```

## Agent指令

```bash
#!/bin/bash
set -e

echo "=========================================="
echo "Issue批准后自动开发流程"
echo "=========================================="

# 1. 获取Issue信息
ISSUE_NUMBER="${GITHUB_EVENT_ISSUE_NUMBER:-}"
if [ -z "$ISSUE_NUMBER" ]; then
    ISSUE_NUMBER=$(echo "${GITHUB_EVENT:-{}}" | jq -r '.issue.number')
fi

ISSUE_TITLE=$(echo "${GITHUB_EVENT:-{}}" | jq -r '.issue.title')
ISSUE_BODY=$(echo "${GITHUB_EVENT:-{}}" | jq -r '.issue.body')

echo "📋 Issue编号: #${ISSUE_NUMBER}"
echo "📝 Issue标题: ${ISSUE_TITLE}"

# 2. 检查评论内容，确认是批准命令
COMMENT_BODY=$(echo "${GITHUB_EVENT:-{}}" | jq -r '.comment.body')
echo "💬 触发评论: ${COMMENT_BODY}"

if [[ ! "$COMMENT_BODY" =~ /(approve|develop) ]]; then
    echo "⚠️  评论不包含批准命令，跳过"
    exit 0
fi

echo "✅ 检测到批准命令，开始开发流程..."

# 3. 回复确认评论
gh issue comment "${ISSUE_NUMBER}" \
    --repo llluchy/Agent-Automate \
    --body "🚀 **开发流程已启动**

Issue #${ISSUE_NUMBER} 已被批准，Agent正在开发中...

## 当前进度
- ✅ 收到批准命令
- 🔄 创建开发分支
- ⏳ 开发功能实现
- ⏳ 编写测试
- ⏳ 运行测试
- ⏳ 创建Pull Request

预计完成时间: 30-60分钟

---
*此评论由Automation自动生成*"

# 4. 创建开发分支
BRANCH_NAME="cursor/issue-${ISSUE_NUMBER}-$(echo "$ISSUE_TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | cut -c1-30)-6dcb"
echo "🌿 创建分支: ${BRANCH_NAME}"

git fetch origin main
git checkout -b "${BRANCH_NAME}" origin/main

# 5. 分析Issue内容，确定开发任务
echo "📖 分析Issue内容..."
echo "标题: ${ISSUE_TITLE}"
echo "内容: ${ISSUE_BODY}"

# 6. 开始开发
# 这里根据Issue的具体内容进行开发
# 示例：如果是测试相关，创建测试文件

if [[ "$ISSUE_TITLE" =~ 测试|test ]]; then
    echo "📝 检测到测试需求，创建测试文件..."
    
    # 创建测试文件
    mkdir -p tests
    cat > "tests/test_issue_${ISSUE_NUMBER}.py" << EOF
# 测试文件 - Issue #${ISSUE_NUMBER}
# ${ISSUE_TITLE}

import pytest

def test_issue_${ISSUE_NUMBER}():
    """
    ${ISSUE_BODY}
    """
    # TODO: 实现具体测试
    assert True

# 更多测试...
EOF

    git add tests/
    echo "✅ 测试文件已创建"
fi

# 如果是功能开发
if [[ "$ISSUE_TITLE" =~ 添加|新增|实现|add|implement ]]; then
    echo "🔨 检测到功能开发需求..."
    
    # 这里添加实际的开发逻辑
    # 根据Issue内容生成代码
    
    echo "⚠️  需要更详细的开发逻辑"
fi

# 7. 提交代码
echo "📦 提交代码..."

git add .
git commit -m "feat(#${ISSUE_NUMBER}): ${ISSUE_TITLE}

- 实现Issue #${ISSUE_NUMBER}中描述的功能
- 根据需求分析自动生成
- 包含测试用例

Issue: #${ISSUE_NUMBER}"

# 8. 推送分支
echo "⬆️  推送分支..."
git push -u origin "${BRANCH_NAME}"

# 9. 创建Pull Request
echo "📬 创建Pull Request..."

PR_BODY="## 关联Issue
Closes #${ISSUE_NUMBER}

## 变更说明
此PR由Agent自动生成，用于解决Issue #${ISSUE_NUMBER}

### Issue内容
${ISSUE_BODY}

## 开发说明
根据Issue需求自动分析并实现功能

## 测试
- [ ] 单元测试已添加
- [ ] 集成测试已添加
- [ ] 手动测试需要人工完成

## 待办
- [ ] 人工审核代码
- [ ] 验证功能完整性
- [ ] 确认符合需求

---
**此PR由Agent自动创建，请仔细审核后再合并**"

gh pr create \
    --repo llluchy/Agent-Automate \
    --base main \
    --head "${BRANCH_NAME}" \
    --title "[自动开发] ${ISSUE_TITLE}" \
    --body "${PR_BODY}" \
    --draft

PR_NUMBER=$(gh pr view "${BRANCH_NAME}" --json number --jq '.number')

# 10. 在Issue中更新进度
gh issue comment "${ISSUE_NUMBER}" \
    --repo llluchy/Agent-Automate \
    --body "✅ **开发完成**

## 完成信息
- 🌿 开发分支: \`${BRANCH_NAME}\`
- 📬 Pull Request: #${PR_NUMBER}
- 📊 状态: Draft（草稿）

## 下一步
请审核PR #${PR_NUMBER}:
1. 查看代码变更
2. 运行测试验证
3. 如果满意，标记为Ready并合并
4. 如果需要修改，在PR中评论

---
*开发完成时间: $(date '+%Y-%m-%d %H:%M:%S')*"

echo "=========================================="
echo "✅ 开发流程完成"
echo "分支: ${BRANCH_NAME}"
echo "PR: #${PR_NUMBER}"
echo "=========================================="
```

## 使用流程

### 1. 创建Issue
```bash
# 手动创建或Agent创建
gh issue create \
  --title "[AI提议] 添加用户登录测试" \
  --body "需要为用户登录功能补充测试用例"
```

### 2. 审批（触发点）
```bash
# 在Issue页面评论
/approve

# 或
/develop
```

### 3. 等待Agent完成
- Agent会立即响应
- 发表进度评论
- 创建分支
- 开发功能
- 创建PR
- 更新完成状态

### 4. 审核PR
- 查看Agent创建的PR
- 审核代码
- 合并或要求修改

## 命令扩展

可以支持更多命令：

```bash
/approve          # 批准开发
/approve urgent   # 批准并标记为紧急
/reject           # 拒绝需求
/discuss          # 需要讨论
/assign @username # 分配给某人
/estimate 2h      # 估算工作量
```

### 扩展Automation配置

创建多个Automations，每个响应不同命令：

**Automation: 拒绝需求**
```yaml
触发: Issue comment 包含 "/reject"
任务: 关闭Issue并说明原因
```

**Automation: 讨论需求**
```yaml
触发: Issue comment 包含 "/discuss"
任务: 添加"需要讨论"标签，@相关人员
```

## 优势

- ✅ 利用唯一可用的Issue触发器
- ✅ 命令式控制，灵活精确
- ✅ 完整的开发流程
- ✅ 可扩展多种命令
- ✅ 清晰的反馈和进度

## 注意事项

1. **评论必须包含命令**：任意评论不会触发，只有包含 `/approve` 的才会

2. **区分命令评论**：可以在评论中添加其他内容
   ```
   这个需求很好，同意开发
   /approve
   ```

3. **避免误触发**：如果只是讨论，不要写 `/approve`

4. **命令格式**：
   - ✅ `/approve`
   - ✅ `/approve urgent`
   - ❌ `approve`（缺少/）
   - ❌ `//approve`（多了/）

## 测试

### 最小测试
1. 创建测试Issue
2. 配置此Automation
3. 在Issue中评论：`/approve`
4. 观察Agent是否开始运行
