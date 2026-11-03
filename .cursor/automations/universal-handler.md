# 通用Automation处理器

> 一个Automation处理所有项目，通过仓库内的配置文件控制行为

## 核心理念

**问题**：每个项目需要3+个Automations，项目多了无法管理

**解决**：
- 只配置1次通用Automations
- 所有项目共享这些Automations  
- 每个项目通过 `.cursor/config.json` 配置行为
- 新项目只需复制配置文件

## 架构

```
全局Automations（只配一次）
├── 通用Issue处理器    → 处理所有仓库的Issue comment
└── 通用定时任务       → 定期扫描所有配置了的仓库

每个项目（快速复制）
└── .cursor/config.json  → 配置该项目的行为
```

## 通用Automation配置

### Automation: 通用Issue处理器

```yaml
名称: 通用Issue处理器
触发: Issue comment（所有仓库）
仓库: *（留空或不限制）
```

### Agent指令

```bash
#!/bin/bash
set -e

echo "=========================================="
echo "通用Issue处理器"
echo "=========================================="

# 1. 获取基本信息
REPO_OWNER=$(echo "${GITHUB_EVENT:-{}}" | jq -r '.repository.owner.login')
REPO_NAME=$(echo "${GITHUB_EVENT:-{}}" | jq -r '.repository.name')
ISSUE_NUMBER=$(echo "${GITHUB_EVENT:-{}}" | jq -r '.issue.number')
COMMENT_BODY=$(echo "${GITHUB_EVENT:-{}}" | jq -r '.comment.body')

echo "📦 仓库: ${REPO_OWNER}/${REPO_NAME}"
echo "📋 Issue: #${ISSUE_NUMBER}"
echo "💬 评论: ${COMMENT_BODY}"

# 2. 克隆仓库并读取配置
git clone "https://github.com/${REPO_OWNER}/${REPO_NAME}.git" repo
cd repo

# 检查配置文件是否存在
if [ ! -f ".cursor/config.json" ]; then
    echo "⚠️  没有找到 .cursor/config.json，跳过处理"
    echo "提示：在仓库根目录创建 .cursor/config.json 来启用自动化"
    exit 0
fi

# 3. 读取配置
echo "📖 读取配置文件..."
CONFIG=$(cat .cursor/config.json)

# 检查是否启用自动化
ENABLED=$(echo "$CONFIG" | jq -r '.automation.enabled // false')
if [ "$ENABLED" != "true" ]; then
    echo "⚠️  自动化未启用，跳过处理"
    exit 0
fi

echo "✅ 自动化已启用"

# 4. 解析命令
COMMAND=$(echo "$COMMENT_BODY" | grep -oP '/(approve|develop|scan|reject|test)' | head -1 || echo "")

if [ -z "$COMMAND" ]; then
    echo "ℹ️  评论不包含命令，跳过处理"
    exit 0
fi

echo "🎯 检测到命令: ${COMMAND}"

# 5. 检查命令是否启用
COMMAND_KEY=$(echo "$COMMAND" | sed 's/\///')
COMMAND_ENABLED=$(echo "$CONFIG" | jq -r ".automation.commands[\"${COMMAND}\"].enabled // false")

if [ "$COMMAND_ENABLED" != "true" ]; then
    echo "⚠️  命令 ${COMMAND} 未启用"
    gh issue comment "${ISSUE_NUMBER}" \
        --repo "${REPO_OWNER}/${REPO_NAME}" \
        --body "⚠️ 命令 \`${COMMAND}\` 未在此项目中启用"
    exit 0
fi

# 6. 获取工作流配置
WORKFLOW=$(echo "$CONFIG" | jq -r ".automation.commands[\"${COMMAND}\"].workflow")
echo "🔄 执行工作流: ${WORKFLOW}"

# 7. 根据工作流执行不同逻辑
case "$WORKFLOW" in
    "develop")
        echo "🔨 开始开发工作流..."
        
        # 读取工作流配置
        CREATE_BRANCH=$(echo "$CONFIG" | jq -r '.automation.workflows.develop.create_branch // true')
        RUN_TESTS=$(echo "$CONFIG" | jq -r '.automation.workflows.develop.run_tests // true')
        CREATE_PR=$(echo "$CONFIG" | jq -r '.automation.workflows.develop.create_pr // true')
        
        # 回复确认
        gh issue comment "${ISSUE_NUMBER}" \
            --repo "${REPO_OWNER}/${REPO_NAME}" \
            --body "🚀 **开发流程已启动**

配置:
- 创建分支: ${CREATE_BRANCH}
- 运行测试: ${RUN_TESTS}
- 创建PR: ${CREATE_PR}

开始开发..."
        
        # 创建分支
        if [ "$CREATE_BRANCH" = "true" ]; then
            ISSUE_TITLE=$(echo "${GITHUB_EVENT:-{}}" | jq -r '.issue.title')
            BRANCH_NAME="cursor/issue-${ISSUE_NUMBER}-$(echo "$ISSUE_TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | cut -c1-30)-6dcb"
            echo "🌿 创建分支: ${BRANCH_NAME}"
            git checkout -b "${BRANCH_NAME}"
            
            # 这里添加实际的开发逻辑
            # ...
            
            git push -u origin "${BRANCH_NAME}"
        fi
        
        # 创建PR
        if [ "$CREATE_PR" = "true" ]; then
            gh pr create \
                --repo "${REPO_OWNER}/${REPO_NAME}" \
                --base main \
                --head "${BRANCH_NAME}" \
                --title "[自动] Issue #${ISSUE_NUMBER}" \
                --body "Closes #${ISSUE_NUMBER}" \
                --draft
        fi
        ;;
        
    "scan-requirements")
        echo "🔍 开始扫描需求..."
        
        CHECK_TODOS=$(echo "$CONFIG" | jq -r '.automation.workflows["scan-requirements"].check_todos // true')
        CHECK_COVERAGE=$(echo "$CONFIG" | jq -r '.automation.workflows["scan-requirements"].check_coverage // false')
        
        if [ "$CHECK_TODOS" = "true" ]; then
            echo "📝 扫描TODO注释..."
            # grep -rn "TODO\|FIXME" . > /tmp/todos.txt
        fi
        ;;
        
    *)
        echo "❌ 未知工作流: ${WORKFLOW}"
        exit 1
        ;;
esac

echo "✅ 完成"
```

## 使用方法

### 1. 一次性配置（全局）

在Cursor中创建一个"通用Issue处理器"Automation，使用上面的指令。

**这是唯一需要在Cursor界面操作的地方！**

### 2. 每个项目（快速复制）

在项目根目录创建 `.cursor/config.json`：

```bash
# 从模板复制
cp /path/to/template/.cursor/config.json .cursor/config.json

# 根据项目调整配置
vim .cursor/config.json
```

### 3. 开始使用

```bash
# 在Issue中评论
/approve

# Automation自动：
# 1. 读取该项目的config.json
# 2. 检查命令是否启用
# 3. 执行对应的工作流
```

## 配置文件说明

```json
{
  "automation": {
    "enabled": true,  // 是否启用自动化
    
    "commands": {
      "/approve": {
        "enabled": true,        // 这个命令是否启用
        "workflow": "develop"    // 使用哪个工作流
      }
    },
    
    "workflows": {
      "develop": {
        "create_branch": true,   // 是否创建分支
        "run_tests": true,       // 是否运行测试
        "create_pr": true        // 是否创建PR
      }
    }
  },
  
  "project": {
    "name": "项目名",
    "type": "experimental",  // experimental | production
    "language": "javascript"
  }
}
```

## 优势

### ✅ 可维护性
- 只需配置1次Automation（全局）
- 修改流程只需更新Automation指令
- 不随项目数量增长

### ✅ 可扩展性
- 新项目只需复制配置文件（5秒）
- 不需要在Cursor界面操作
- 配置文件可以版本控制

### ✅ 灵活性
- 每个项目独立配置
- 可以禁用某些功能
- 实验性项目可以最小化配置

### ✅ 可复制性
```bash
# 新项目
cp ../template/.cursor/config.json .cursor/
git add .cursor/config.json
git commit -m "启用自动化"
git push

# 完成！无需在Cursor界面操作
```

## 项目数量对比

| 方案 | 10个项目 | 新项目成本 |
|-----|---------|-----------|
| **之前（多Automation）** | 30个Automations | 配置3个Automations（20分钟） |
| **现在（配置文件）** | 1个Automation | 复制配置文件（30秒） |

## 配置文件模板

### 最小配置（快速尝试新项目）
```json
{
  "automation": {
    "enabled": true,
    "commands": {
      "/approve": {
        "enabled": true,
        "workflow": "develop"
      }
    }
  }
}
```

### 完整配置（生产项目）
```json
{
  "automation": {
    "enabled": true,
    "commands": {
      "/approve": { "enabled": true, "workflow": "develop" },
      "/scan": { "enabled": true, "workflow": "scan-requirements" },
      "/test": { "enabled": true, "workflow": "run-tests" },
      "/reject": { "enabled": true, "workflow": "close-issue" }
    },
    "schedule": {
      "scan_requirements": {
        "enabled": true,
        "cron": "0 9 * * *"
      }
    },
    "workflows": {
      "develop": {
        "create_branch": true,
        "run_tests": true,
        "create_pr": true,
        "pr_draft": true,
        "auto_close_issue": false
      },
      "scan-requirements": {
        "check_todos": true,
        "check_coverage": true,
        "check_dependencies": true,
        "create_issues": true
      }
    }
  },
  "project": {
    "name": "Production App",
    "type": "production",
    "language": "javascript",
    "test_command": "npm test",
    "build_command": "npm run build",
    "lint_command": "npm run lint"
  }
}
```

### 禁用配置（暂停自动化）
```json
{
  "automation": {
    "enabled": false
  }
}
```

## 快速开始

### 第1步：创建通用Automation（一次性）
在Cursor创建1个Automation，使用上面的通用处理器指令。

### 第2步：在项目中添加配置
```bash
mkdir -p .cursor
cat > .cursor/config.json << 'EOF'
{
  "automation": {
    "enabled": true,
    "commands": {
      "/approve": {
        "enabled": true,
        "workflow": "develop"
      }
    }
  }
}
EOF
git add .cursor/config.json
git commit -m "启用自动化"
git push
```

### 第3步：使用
在Issue中评论 `/approve` 即可！

## 总结

从此以后：
- ✅ 只需维护1个Automation（全局）
- ✅ 新项目30秒启用（复制配置）
- ✅ 配置在仓库中（可追溯、可回滚）
- ✅ 随性开新项目不再有负担
