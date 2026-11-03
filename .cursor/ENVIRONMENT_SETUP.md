# 多项目Environment隔离指南

> 确保每个项目有独立的上下文、记忆和配置

## 🎯 为什么需要独立Environment？

### 问题场景：

```
共享Environment的问题：

项目A（React前端）
  ├── Agent记住：用React Hooks
  ├── Agent记住：用Material-UI
  └── Agent记住：测试用Jest

项目B（Node后端）调用同一个Agent
  └── Agent错误地：
      ❌ 建议用React组件
      ❌ 导入Material-UI
      ❌ 用前端测试方式
```

### 独立Environment的好处：

```
项目A → Environment A
  ✅ 记得React项目特点
  ✅ 代码风格正确
  ✅ 依赖版本准确

项目B → Environment B  
  ✅ 记得Node后端特点
  ✅ 不会混淆前端代码
  ✅ 使用正确的模式
```

---

## 🏗️ Environment层级结构

### 层级设计：

```
个人账户
├── Environment: 默认通用环境
│   └── 用于：临时测试、一次性任务
│
├── Environment: 前端项目模板
│   ├── 用于：所有React/Vue前端项目
│   └── 包含：前端通用配置、工具链
│
├── Environment: 后端项目模板
│   ├── 用于：所有Node/Python后端项目
│   └── 包含：后端通用配置、数据库工具
│
├── Environment: 项目A专属
│   ├── 继承：前端项目模板
│   └── 包含：项目A特定配置、记忆
│
└── Environment: 项目B专属
    ├── 继承：后端项目模板
    └── 包含：项目B特定配置、记忆
```

---

## 📋 配置步骤

### 第1步：创建项目专属Environment

#### 方法1：在Cursor Dashboard创建

```
1. 访问：https://cursor.com/settings/environments

2. 点击"New Environment"

3. 填写信息：
   名称: Agent-Automate Dev
   描述: Agent-Automate项目开发环境
   基础环境: 选择模板或默认
   
4. 配置：
   - 仓库：llluchy/Agent-Automate
   - 分支：main
   - Install脚本：npm install
   - Start脚本：（可选）
   
5. 保存并记录Environment ID
   例如：env_agent_automate_main_xxx
```

#### 方法2：通过API创建（推荐用于批量）

```bash
curl -X POST "https://api.cursor.com/v1/environments" \
  -H "Authorization: Bearer ${CURSOR_API_KEY}" \
  -d '{
    "name": "Agent-Automate Dev",
    "description": "Agent-Automate项目开发环境",
    "config": {
      "repository": "llluchy/Agent-Automate",
      "branch": "main",
      "install": "npm install",
      "memory_file": ".cursor/memory.json",
      "context_file": ".cursor/context.json"
    }
  }'

# 响应包含 environment_id
```

### 第2步：在项目配置中指定Environment

编辑 `.cursor/config.json`：

```json
{
  "cursor": {
    "environment_id": "env_agent_automate_main_xxx",  ← 填入实际ID
    "memory_file": ".cursor/memory.json",
    "context_file": ".cursor/context.json"
  },
  "project": {
    "name": "Agent-Automate",
    ...
  }
}
```

### 第3步：初始化项目记忆和上下文

#### 记忆文件（`.cursor/memory.json`）

记录项目的长期知识：

```json
{
  "project_knowledge": {
    "name": "项目名",
    "primary_language": "javascript",
    "code_style": {
      "indent": "2 spaces",
      "quotes": "single"
    },
    "architecture": {
      "type": "微服务",
      "patterns": ["MVC", "Repository"]
    }
  },
  
  "conversation_history": [
    {
      "date": "2026-11-03",
      "topic": "架构决策",
      "key_decisions": [
        "使用PostgreSQL而非MySQL",
        "采用RESTful API而非GraphQL"
      ]
    }
  ],
  
  "agent_notes": [
    "用户偏好简洁的代码",
    "测试覆盖率要求>80%"
  ]
}
```

#### 上下文文件（`.cursor/context.json`）

记录当前项目状态：

```json
{
  "current_focus": [
    "优化数据库查询性能",
    "实现用户认证系统"
  ],
  
  "tech_stack": {
    "backend": "Node.js + Express",
    "database": "PostgreSQL",
    "cache": "Redis"
  },
  
  "recent_changes": [
    {
      "date": "2026-11-03",
      "change": "迁移到TypeScript",
      "reason": "提高类型安全"
    }
  ]
}
```

---

## 🔄 Agent如何使用Environment

### 触发流程：

```
1. GitHub Actions检测到 /approve 评论
   ↓
2. 读取仓库的 .cursor/config.json
   ↓
3. 获取 environment_id
   ↓
4. 调用Cursor API时指定Environment：
   
   curl -X POST "https://api.cursor.com/v1/agents" \
     -d '{
       "environment": "env_agent_automate_main_xxx",  ← 指定Environment
       "task": "开发Issue #123",
       ...
     }'
   ↓
5. Agent在该Environment中启动
   ↓
6. Agent自动加载：
   - Environment配置（仓库、依赖等）
   - 项目记忆（.cursor/memory.json）
   - 项目上下文（.cursor/context.json）
   ↓
7. Agent带着正确的项目知识开发
```

### Agent读取记忆的方式：

```bash
# Agent启动时自动执行
MEMORY=$(cat .cursor/memory.json)
CONTEXT=$(cat .cursor/context.json)

# 从记忆中获取信息
CODE_STYLE=$(echo $MEMORY | jq -r '.project_knowledge.code_style')
LANGUAGE=$(echo $MEMORY | jq -r '.project_knowledge.primary_language')

# 使用这些信息指导开发
echo "使用${LANGUAGE}开发，代码风格：${CODE_STYLE}"
```

---

## 📊 多项目Environment管理

### 策略1：每项目独立Environment

```
适合：
- 长期维护的生产项目
- 有特殊配置的项目
- 需要隔离的敏感项目

示例：
项目A → env_project_a
项目B → env_project_b
项目C → env_project_c
```

### 策略2：按类型共享Environment

```
适合：
- 大量相似的小项目
- 实验性项目
- 快速原型

示例：
前端项目1 → env_frontend_template
前端项目2 → env_frontend_template
前端项目3 → env_frontend_template

后端项目1 → env_backend_template
后端项目2 → env_backend_template
```

### 策略3：混合策略（推荐）

```
生产项目：独立Environment
  - 重要、长期维护
  - 完整的记忆和上下文

实验项目：共享模板Environment  
  - 快速尝试、可能废弃
  - 最小配置

临时任务：默认Environment
  - 一次性任务
  - 无需持久化
```

---

## 🚀 新项目快速配置

### 场景1：从模板创建新项目

```bash
# 1. 从模板克隆（自动带上配置文件）
git clone template-repo my-new-project
cd my-new-project

# 2. 决定Environment策略
# 选项A：创建专属Environment
curl -X POST "https://api.cursor.com/v1/environments" \
  -H "Authorization: Bearer ${CURSOR_API_KEY}" \
  -d '{
    "name": "MyNewProject Dev",
    "repository": "user/my-new-project"
  }'

# 选项B：使用现有模板Environment
# 不需要创建，直接使用模板的 environment_id

# 3. 更新配置文件
vim .cursor/config.json
# 修改 environment_id（如果需要）
# 修改 project.name

# 4. 初始化项目记忆
vim .cursor/memory.json
# 更新项目信息

# 5. 提交
git add .cursor/
git commit -m "配置项目Environment"
git push

# 完成！
```

### 场景2：快速实验项目

```bash
# 1. 创建项目
mkdir quick-experiment && cd quick-experiment
git init

# 2. 复制最小配置
cat > .cursor/config.json << 'EOF'
{
  "cursor": {
    "environment_id": "env_experimental_shared"  ← 共享Environment
  },
  "project": {
    "name": "Quick Experiment",
    "type": "experimental"
  }
}
EOF

# 3. 完成！
# 使用共享Environment，无需创建专属环境
```

---

## 🔧 Environment内容管理

### 什么放在Environment配置中？

```yaml
Environment配置：
✅ 仓库URL
✅ 默认分支
✅ Install命令
✅ Start命令
✅ 环境变量（非敏感）
✅ 依赖版本锁定

不要放：
❌ 敏感信息（用Secrets）
❌ 频繁变化的内容（用记忆文件）
```

### 什么放在记忆文件中？

```yaml
.cursor/memory.json：
✅ 代码风格偏好
✅ 架构决策
✅ 重要的对话历史
✅ 已知问题和解决方案
✅ Agent的学习笔记

更新频率：每周/每月
```

### 什么放在上下文文件中？

```yaml
.cursor/context.json：
✅ 当前关注点
✅ 最近的变更
✅ 技术栈（可能变化）
✅ 活跃功能
✅ 临时配置

更新频率：每天/每周
```

---

## 📈 最佳实践

### 1. Environment命名规范

```
格式：env_{project}_{type}_{variant}

示例：
env_myapp_prod_main      - MyApp生产环境主分支
env_myapp_dev_main       - MyApp开发环境主分支
env_myapp_feature_auth   - MyApp功能分支（auth功能）
env_frontend_template    - 前端项目模板
env_experimental_shared  - 实验项目共享环境
```

### 2. 定期更新记忆

```bash
# 每周回顾
1. 阅读 .cursor/memory.json
2. 添加新的重要决策
3. 更新 agent_notes
4. 提交更新

git add .cursor/memory.json
git commit -m "docs: 更新项目记忆"
```

### 3. 记忆版本控制

```bash
# 记忆文件应该版本控制
git add .cursor/memory.json .cursor/context.json
git commit -m "docs: 更新项目记忆和上下文"

# 好处：
✅ 可以回溯历史决策
✅ 团队成员同步知识
✅ 可以跨分支共享
```

### 4. Environment切换

```bash
# 如果需要在不同Environment测试
# 1. 备份当前配置
cp .cursor/config.json .cursor/config.json.bak

# 2. 修改environment_id
vim .cursor/config.json

# 3. 测试
# ...

# 4. 恢复
mv .cursor/config.json.bak .cursor/config.json
```

---

## 🎓 实际案例

### 案例1：前端项目（React）

```json
// .cursor/config.json
{
  "cursor": {
    "environment_id": "env_myreactapp_dev"
  },
  "project": {
    "name": "MyReactApp",
    "language": "javascript",
    "framework": "React",
    "test_command": "npm test"
  }
}

// .cursor/memory.json
{
  "project_knowledge": {
    "primary_language": "javascript",
    "framework": "React 18",
    "state_management": "Redux Toolkit",
    "ui_library": "Material-UI",
    
    "code_style": {
      "component_style": "functional-hooks",
      "import_order": ["react", "third-party", "local"],
      "file_naming": "PascalCase.jsx"
    },
    
    "conventions": {
      "component_structure": "container-presenter pattern",
      "test_location": "__tests__ folder"
    }
  },
  
  "agent_notes": [
    "始终使用TypeScript类型",
    "组件必须有PropTypes或TypeScript类型",
    "避免使用class组件，优先用hooks"
  ]
}
```

### 案例2：后端项目（Node.js）

```json
// .cursor/config.json
{
  "cursor": {
    "environment_id": "env_myapi_backend_dev"
  },
  "project": {
    "name": "MyAPI",
    "language": "javascript",
    "framework": "Express",
    "test_command": "npm run test:api"
  }
}

// .cursor/memory.json
{
  "project_knowledge": {
    "primary_language": "javascript",
    "framework": "Express 4",
    "database": "PostgreSQL",
    "orm": "Prisma",
    
    "architecture": {
      "type": "layered",
      "layers": ["routes", "controllers", "services", "repositories"]
    },
    
    "code_style": {
      "async_style": "async/await",
      "error_handling": "try-catch with custom errors",
      "validation": "Joi schemas"
    }
  },
  
  "agent_notes": [
    "所有API端点必须有认证中间件",
    "数据库操作必须在transaction中",
    "错误响应遵循统一格式"
  ]
}
```

---

## 🔗 与GitHub Actions集成

### 更新GitHub Actions配置

```yaml
# .github/workflows/cursor-trigger.yml
- name: 调用Cursor Agent
  env:
    CURSOR_API_KEY: ${{ secrets.CURSOR_API_KEY }}
  run: |
    # 读取项目配置
    ENV_ID=$(jq -r '.cursor.environment_id' .cursor/config.json)
    
    # 使用项目专属Environment
    curl -X POST "https://api.cursor.com/v1/agents" \
      -H "Authorization: Bearer ${CURSOR_API_KEY}" \
      -d '{
        "environment": "'"${ENV_ID}"'",  ← 使用配置的Environment
        "task": "开发Issue #${{ github.event.issue.number }}",
        "repository": "${{ github.repository }}"
      }'
```

---

## 总结

### 核心要点：

1. **每个重要项目一个Environment**
   - 隔离上下文
   - 独立记忆
   - 准确的代码建议

2. **配置文件三件套**
   - `config.json` - 指定Environment
   - `memory.json` - 长期知识
   - `context.json` - 当前状态

3. **灵活的策略**
   - 生产项目：专属Environment
   - 实验项目：共享Environment
   - 临时任务：默认Environment

4. **记忆版本控制**
   - 提交记忆文件
   - 追溯历史决策
   - 团队知识共享

### 效果：

```
✅ Agent永远记得正确的项目信息
✅ 不同项目不会互相干扰
✅ 新项目快速复制配置
✅ 随项目演进更新记忆
✅ 团队成员共享知识
```

这样，每次触发Agent，都会带着该项目专属的记忆和上下文！🎉
