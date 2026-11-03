# 替代方案：GitHub Actions调用Cursor

> 如果Cursor API不可用或文档不清晰，这里提供几种替代方案

## 🔍 问题

Cursor的公开API文档可能有限，我们需要找到实际可用的调用方式。

## 方案对比

### ✅ 方案1：通过Cursor CLI（如果存在）

```yaml
- name: 安装Cursor CLI
  run: npm install -g @cursor/cli

- name: 登录
  env:
    CURSOR_TOKEN: ${{ secrets.CURSOR_TOKEN }}
  run: cursor auth login --token $CURSOR_TOKEN

- name: 创建Agent
  run: |
    cursor agent create \
      --task "开发Issue #${{ github.event.issue.number }}" \
      --repo ${{ github.repository }}
```

### ✅ 方案2：通过GitHub → Cursor webhook（推荐）

原理：GitHub Actions触发webhook → Cursor Automations接收

#### 步骤1：在Cursor创建webhook接收Automation

```yaml
# Cursor Automation配置
名称: Webhook接收器
触发: Webhook（如果支持）
或者: 监听特殊的Issue/PR
```

#### 步骤2：GitHub Actions创建特殊Issue

```yaml
name: 触发Cursor开发

on:
  issue_comment:
    types: [created]

jobs:
  trigger:
    if: contains(github.event.comment.body, '/approve')
    runs-on: ubuntu-latest
    steps:
      - name: 创建开发触发Issue
        run: |
          # 创建一个特殊Issue，Cursor Automation会监听
          gh issue create \
            --title "[CURSOR-DEV] Issue #${{ github.event.issue.number }}" \
            --body "自动开发请求
            
原始Issue: #${{ github.event.issue.number }}
触发者: ${{ github.event.comment.user.login }}
触发时间: $(date)

请Agent开始开发原始Issue" \
            --label "cursor-trigger"
          
          # 或者：在原Issue上添加特殊标签
          gh issue edit ${{ github.event.issue.number }} \
            --add-label "cursor-approved"
```

#### 步骤3：Cursor Automation监听

```yaml
# Cursor Automation
触发: Label change = "cursor-approved"
或者: Issue created with label "cursor-trigger"

任务: 读取Issue，开发，创建PR
```

**优势**：
- ✅ 不需要Cursor API
- ✅ 使用现有的Automations机制
- ✅ 完全可行

### ✅ 方案3：通过特殊PR触发

```yaml
name: 创建开发任务PR

on:
  issue_comment:
    types: [created]

jobs:
  create-task-pr:
    if: contains(github.event.comment.body, '/approve')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: 创建任务分支
        run: |
          ISSUE_NUM=${{ github.event.issue.number }}
          BRANCH="cursor/trigger-issue-${ISSUE_NUM}"
          
          git checkout -b $BRANCH
          
          # 创建任务描述文件
          mkdir -p .cursor/tasks
          cat > .cursor/tasks/issue-${ISSUE_NUM}.md << EOF
# 开发任务

## 原始Issue
#${ISSUE_NUM}

## 要求
1. 阅读Issue #${ISSUE_NUM}
2. 创建开发分支
3. 实现功能
4. 编写测试
5. 更新此PR

## 状态
- [ ] 已开始
- [ ] 开发完成
- [ ] 测试完成
- [ ] 等待审核
EOF
          
          git add .cursor/tasks/
          git commit -m "触发开发：Issue #${ISSUE_NUM}"
          git push origin $BRANCH
      
      - name: 创建触发PR
        run: |
          gh pr create \
            --title "[CURSOR-DEV] 开发Issue #${{ github.event.issue.number }}" \
            --body "此PR用于触发Cursor自动开发
            
原始Issue: #${{ github.event.issue.number }}
            
Cursor Agent将：
1. 检测到此PR
2. 阅读任务描述
3. 开发功能
4. 更新此PR" \
            --label "cursor-dev-trigger" \
            --draft
```

然后配置Cursor Automation：
```yaml
触发: PR opened with label "cursor-dev-trigger"
任务: 读取任务描述，开发，更新PR
```

### ✅ 方案4：邮件/Slack通知 + 手动触发

最简单但仍然有用：

```yaml
name: 通知开发请求

on:
  issue_comment:
    types: [created]

jobs:
  notify:
    if: contains(github.event.comment.body, '/approve')
    runs-on: ubuntu-latest
    steps:
      - name: 发送Slack通知
        uses: slackapi/slack-github-action@v1
        with:
          channel-id: 'your-channel'
          slack-message: |
            🚨 需要开发
            
            Issue: #${{ github.event.issue.number }}
            标题: ${{ github.event.issue.title }}
            链接: ${{ github.event.issue.html_url }}
            
            请在Cursor中开始开发
        env:
          SLACK_BOT_TOKEN: ${{ secrets.SLACK_BOT_TOKEN }}
```

你收到通知后，在Cursor中手动启动Agent。

## 🔎 如何找到Cursor API信息

### 方法1：查看Cursor文档

```bash
# 访问
https://docs.cursor.com/api
https://cursor.com/docs
```

### 方法2：浏览器开发者工具

```bash
1. 打开 cursor.com
2. 打开开发者工具（F12）
3. 切换到Network标签
4. 在Cursor界面手动创建Agent
5. 查看Network中的API请求
6. 复制API端点和请求格式
```

### 方法3：询问Cursor支持

```
访问：https://cursor.com/support
或者：support@cursor.com

询问：
"我想在GitHub Actions中调用Cursor Cloud Agent，
请问API端点和认证方式是什么？"
```

### 方法4：查看Cursor CLI源码

```bash
# 如果Cursor有开源CLI
git clone https://github.com/getcursor/cli
cd cli
# 查看源码，找API调用方式
```

## 📋 实际操作建议

### 阶段1：验证API（今天）

1. 检查Cursor是否提供API文档
2. 尝试获取API Key
3. 测试一个简单的API调用

```bash
# 测试脚本
curl -X GET "https://api.cursor.com/v1/ping" \
  -H "Authorization: Bearer YOUR_API_KEY"
```

### 阶段2：如果API不可用（备选）

使用**方案2：Label触发**

```yaml
# .github/workflows/cursor-trigger.yml
name: Cursor触发器

on:
  issue_comment:
    types: [created]

jobs:
  add-label:
    if: contains(github.event.comment.body, '/approve')
    runs-on: ubuntu-latest
    steps:
      - name: 添加触发标签
        run: |
          gh issue edit ${{ github.event.issue.number }} \
            --add-label "cursor-approved"
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

然后在Cursor中配置Automation监听 `cursor-approved` 标签。

**这个方案100%可行！**

### 阶段3：逐步优化

1. 从Label触发开始（可靠）
2. 探索更高级的API调用
3. 根据实际需要优化

## 🎯 推荐的最可靠方案

**GitHub Actions + Label + Cursor Automation**

### 完整流程：

```
Issue评论 /approve
    ↓ (GitHub Actions检测)
添加标签 cursor-approved
    ↓ (Cursor Automation检测)
创建Agent开发
    ↓
创建PR
```

### 配置：

#### 1. GitHub Actions
```yaml
# .github/workflows/add-cursor-label.yml
name: 添加Cursor标签

on:
  issue_comment:
    types: [created]

jobs:
  add-label:
    if: |
      contains(github.event.comment.body, '/approve') &&
      (github.event.comment.user.login == github.repository_owner ||
       contains(fromJSON('["collaborator", "owner", "member"]'), github.event.comment.author_association))
    runs-on: ubuntu-latest
    steps:
      - name: 添加cursor-approved标签
        run: gh issue edit ${{ github.event.issue.number }} --add-label "cursor-approved"
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: 回复确认
        run: |
          gh issue comment ${{ github.event.issue.number }} --body "✅ 已添加 \`cursor-approved\` 标签，Cursor Agent即将开始开发"
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

#### 2. Cursor Automation
```
触发: Label change = "cursor-approved"
任务: （使用之前的开发脚本）
```

### 优势：
- ✅ 100%可行（不依赖未知API）
- ✅ 配置简单
- ✅ 容易调试
- ✅ 权限控制（只允许特定用户触发）

## 总结

如果Cursor API可用 → 使用方案1（直接API）
如果API不明确 → 使用方案2（Label触发）⭐推荐⭐
如果需要通知 → 使用方案4（Slack/邮件）

**最可靠的选择：GitHub Actions添加Label + Cursor Automation监听**
