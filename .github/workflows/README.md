# GitHub Actions + Cursor集成指南

> 用GitHub Actions触发Cursor Cloud Agent

## 🎯 目标

实现完全自动化的开发流程，无需手动配置Automations：

```
Issue评论 /approve
    ↓ (GitHub Actions触发)
调用Cursor API
    ↓
创建Cloud Agent
    ↓
Agent自动开发
    ↓
创建PR
```

## 📋 前置要求

### 1. Cursor API Key

需要获取Cursor API密钥：

**方法1：从Cursor Dashboard获取**
```
1. 访问：https://cursor.com/settings/api
2. 创建API Key
3. 复制密钥（格式：cur_xxx...）
```

**方法2：使用Cursor CLI**
```bash
# 安装Cursor CLI（如果有）
npm install -g @cursor/cli

# 登录
cursor login

# 获取API key
cursor api-key create --name "GitHub Actions"
```

### 2. Environment ID

获取你的Cursor开发环境ID：

```bash
# 方法1：通过API查询
curl https://api.cursor.com/v1/environments \
  -H "Authorization: Bearer ${CURSOR_API_KEY}"

# 方法2：从Dashboard URL获取
# 访问 https://cursor.com/settings
# Environment ID通常在URL或页面中显示
```

### 3. GitHub Secrets配置

在仓库中配置Secrets：

```
访问：https://github.com/你的用户名/仓库名/settings/secrets/actions

添加Secrets：
1. CURSOR_API_KEY = cur_xxx...（从步骤1获取）
2. CURSOR_ENVIRONMENT_ID = env_xxx...（从步骤2获取）
```

## 🚀 快速开始

### 1. 复制GitHub Actions配置

已经在 `.github/workflows/cursor-auto-dev.yml` 中

### 2. 提交到仓库

```bash
git add .github/workflows/
git commit -m "添加Cursor自动化"
git push
```

### 3. 测试

```bash
# 创建测试Issue
gh issue create --title "测试自动化" --body "这是测试"

# 在Issue中评论
# 访问Issue页面，评论：/approve

# GitHub Actions会自动：
# 1. 检测到评论
# 2. 调用Cursor API
# 3. 创建Agent
# 4. Agent开发
# 5. 创建PR
```

## 🔧 Cursor API参考

### 创建Agent

```bash
POST https://api.cursor.com/v1/agents
Authorization: Bearer ${CURSOR_API_KEY}
Content-Type: application/json

{
  "environment": "env_xxx",      # 环境ID
  "task": "开发任务描述",          # Agent要做的事
  "repository": "owner/repo",    # GitHub仓库
  "branch": "main",              # 基础分支
  "metadata": {                  # 可选的元数据
    "issue_number": 123,
    "trigger": "github_actions"
  }
}

Response:
{
  "id": "agent_xxx",             # Agent ID
  "url": "https://cursor.com/agents/agent_xxx",
  "status": "running",
  "created_at": "2026-11-03T10:00:00Z"
}
```

### 查询Agent状态

```bash
GET https://api.cursor.com/v1/agents/{agent_id}
Authorization: Bearer ${CURSOR_API_KEY}

Response:
{
  "id": "agent_xxx",
  "status": "running" | "completed" | "failed",
  "progress": {
    "current_step": "creating_branch",
    "completed_steps": ["analyze_issue"],
    "total_steps": 5
  },
  "output": {
    "branch": "cursor/issue-123-xxx",
    "pr_number": 456
  }
}
```

### 停止Agent

```bash
POST https://api.cursor.com/v1/agents/{agent_id}/stop
Authorization: Bearer ${CURSOR_API_KEY}
```

## 📊 完整工作流示例

### Workflow文件结构

```yaml
name: Cursor自动开发

# 触发条件
on:
  issue_comment:
    types: [created]

# 作业
jobs:
  trigger-agent:
    if: contains(github.event.comment.body, '/approve')
    runs-on: ubuntu-latest
    steps:
      - name: 调用Cursor API
        # 见 cursor-auto-dev.yml
```

### 高级配置

#### 1. 支持多种命令

```yaml
on:
  issue_comment:
    types: [created]

jobs:
  route-command:
    runs-on: ubuntu-latest
    steps:
      - name: 解析命令
        id: parse
        run: |
          COMMENT="${{ github.event.comment.body }}"
          
          if [[ "$COMMENT" == *"/approve"* ]]; then
            echo "command=approve" >> $GITHUB_OUTPUT
          elif [[ "$COMMENT" == *"/scan"* ]]; then
            echo "command=scan" >> $GITHUB_OUTPUT
          elif [[ "$COMMENT" == *"/test"* ]]; then
            echo "command=test" >> $GITHUB_OUTPUT
          fi
      
      - name: 执行对应任务
        if: steps.parse.outputs.command != ''
        run: |
          # 根据命令调用不同的Cursor Agent任务
```

#### 2. 定时扫描需求

```yaml
name: 定时扫描需求

on:
  schedule:
    - cron: '0 9 * * *'  # 每天早上9点

jobs:
  scan-requirements:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: 调用Cursor扫描Agent
        env:
          CURSOR_API_KEY: ${{ secrets.CURSOR_API_KEY }}
        run: |
          curl -X POST "https://api.cursor.com/v1/agents" \
            -H "Authorization: Bearer ${CURSOR_API_KEY}" \
            -d '{
              "environment": "${{ secrets.CURSOR_ENVIRONMENT_ID }}",
              "task": "扫描代码库，发现待改进点，创建Issues",
              "repository": "${{ github.repository }}"
            }'
```

#### 3. PR创建后自动测试

```yaml
name: PR自动测试

on:
  pull_request:
    types: [opened, synchronize]
    # 只处理Agent创建的PR
    branches-ignore:
      - main

jobs:
  auto-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: 调用Cursor测试Agent
        env:
          CURSOR_API_KEY: ${{ secrets.CURSOR_API_KEY }}
        run: |
          curl -X POST "https://api.cursor.com/v1/agents" \
            -H "Authorization: Bearer ${CURSOR_API_KEY}" \
            -d '{
              "environment": "${{ secrets.CURSOR_ENVIRONMENT_ID }}",
              "task": "全面测试PR #${{ github.event.pull_request.number }}",
              "repository": "${{ github.repository }}",
              "branch": "${{ github.head_ref }}"
            }'
```

## 🎓 新项目使用

### 方法1：模板仓库

```bash
# 1. 将这个仓库设为模板
# GitHub → Settings → Template repository ✅

# 2. 从模板创建新项目
gh repo create my-new-app \
  --template llluchy/Agent-Automate \
  --private

# 3. 配置Secrets（只需一次）
gh secret set CURSOR_API_KEY -b "cur_xxx..."
gh secret set CURSOR_ENVIRONMENT_ID -b "env_xxx..."

# 完成！GitHub Actions已经配好了
```

### 方法2：手动复制

```bash
# 创建新项目
mkdir my-new-app && cd my-new-app
git init

# 复制Actions配置
mkdir -p .github/workflows
cp /path/to/template/.github/workflows/*.yml .github/workflows/

# 提交
git add .github/workflows/
git commit -m "添加自动化"
git push
```

## ⚠️ 注意事项

### 1. API限制

- Cursor API可能有速率限制
- 建议添加重试逻辑
- 注意并发Agent数量限制

### 2. 安全性

- API Key保存在GitHub Secrets中
- 不要在代码中硬编码
- 定期轮换API密钥

### 3. 成本

- Cursor Cloud Agent按使用计费
- 设置合理的超时时间
- 监控使用情况

## 🔍 故障排查

### Actions运行但Agent未创建

检查：
1. API Key是否正确
2. Environment ID是否正确
3. 查看Actions日志中的API响应

### Agent创建成功但没有产出

1. 访问Agent URL查看详细日志
2. 检查Agent的错误信息
3. 可能是任务描述不够清晰

### 权限问题

确保：
1. GitHub Token有足够权限
2. Cursor API Key有效
3. 仓库配置正确

## 📚 参考链接

- Cursor API文档：https://docs.cursor.com/api
- GitHub Actions文档：https://docs.github.com/actions
- 示例仓库：https://github.com/llluchy/Agent-Automate

## 🎉 优势总结

使用GitHub Actions + Cursor API的优势：

✅ **配置在仓库内**
- `.github/workflows/` 随仓库走
- 新项目自动继承
- 可以版本控制

✅ **无需手动配置Automations**
- 不需要在Cursor界面操作
- 所有配置都是代码
- 容易维护和复制

✅ **灵活性**
- 可以自定义触发条件
- 可以添加额外步骤
- 可以集成其他服务

✅ **可扩展性**
- 轻松添加新工作流
- 支持复杂场景
- 社区有大量Actions可用

✅ **零Automation管理负担**
- 不随项目数量增长
- 每个项目独立
- 随性开新项目无压力
