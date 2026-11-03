# GitHub Actions 配置完成 ✅

## 已创建的工作流

### 1. Issue触发开发（issue-trigger.yml）
- 监听：Issue评论包含 `/approve`
- 动作：添加 `cursor-approved` 标签
- 权限：仅owner和collaborators

### 2. 每日定时扫描（daily-scan.yml）  
- 时间：每天早上9点（北京时间）
- 扫描：TODO/FIXME注释
- 动作：自动创建Issue（标签：`ai-proposed`）

---

## ⚠️ 需要手动创建Labels

访问：https://github.com/llluchy/Agent-Automate/labels/new

### 创建2个标签：

**1. cursor-approved**
- 颜色：`#0e8a16`（绿色）
- 描述：已批准，等待Cursor Agent开发

**2. ai-proposed**  
- 颜色：`#d4c5f9`（淡紫色）
- 描述：AI提议的改进，等待审批

**3. automated-scan**（可选）
- 颜色：`#1d76db`（蓝色）
- 描述：每日自动扫描生成

---

## 🧪 测试

### 测试定时扫描（手动触发）

```bash
# 访问Actions页面手动触发
https://github.com/llluchy/Agent-Automate/actions/workflows/daily-scan.yml

点击 "Run workflow"
```

### 测试Issue触发

```bash
# 1. 创建测试Issue
gh issue create --title "测试自动化" --body "测试"

# 2. 在Issue中评论
/approve

# 3. 观察结果
# - Issue应该被添加 cursor-approved 标签
# - 收到确认评论
```

---

## 🔗 下一步：配置Cursor Automation

创建Cursor Automation监听 `cursor-approved` 标签：

```yaml
触发: Label change
标签: cursor-approved
仓库: llluchy/Agent-Automate

指令: 使用 .cursor/automations/issue-approve-develop.md
```

---

## 📊 完整流程

```
每天9点
    ↓
定时扫描 → 创建Issue（ai-proposed）
    ↓
你审批 → 评论 /approve
    ↓
GitHub Actions → 添加 cursor-approved 标签
    ↓
Cursor Automation → Agent开发 → PR
```

全部自动化！✅
