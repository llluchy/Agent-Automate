# 脚本工具集

本目录包含辅助脚本，用于项目自动化和管理。

## 📁 可用脚本

### `create-issues-helper.sh`

**用途**: 帮助创建AI分析生成的改进Issues

**功能**:
- 批量创建所有5个Issues
- 选择性创建高优先级Issues
- 单独创建某个Issue
- 导出Issues内容到独立文件
- 显示手动创建命令

**使用方法**:

```bash
# 运行助手
./scripts/create-issues-helper.sh

# 按照提示选择操作：
# 1 - 创建所有Issues
# 2 - 只创建高优先级Issues
# 3 - 选择性创建
# 4 - 显示创建命令
# 5 - 导出到文件
```

**前置条件**:
- 已安装 `gh` CLI（可选，如果没有会提示手动创建）
- 已登录GitHub账户（如果使用gh CLI）
- 已拉取最新代码（包含 `.cursor/proposed-issues.md`）

**输出**:
- 选项1-3: 在GitHub上创建Issues
- 选项4: 在终端显示命令
- 选项5: 在 `.cursor/issues-export/` 目录生成Markdown文件

---

## 🚀 快速开始

### 场景1：直接创建所有Issues

```bash
./scripts/create-issues-helper.sh
# 选择: 1
```

### 场景2：先导出查看，再手动创建

```bash
./scripts/create-issues-helper.sh
# 选择: 5

# 查看导出的文件
ls .cursor/issues-export/
cat .cursor/issues-export/issue-1.md

# 然后手动访问GitHub创建Issues
```

### 场景3：只创建最重要的2个Issues

```bash
./scripts/create-issues-helper.sh
# 选择: 2
```

---

## 📝 手动创建Issues

如果脚本无法自动创建（权限问题），可以手动创建：

### 步骤：

1. **访问GitHub**  
   https://github.com/llluchy/Agent-Automate/issues/new

2. **复制内容**  
   从 `.cursor/proposed-issues.md` 或 `.cursor/issues-export/issue-X.md` 复制

3. **填写表单**
   - 标题: `[AI提议] <Issue标题>`
   - 内容: 复制的完整Markdown
   - 标签: 按建议添加（如 `ai-proposed`, `enhancement`）

4. **提交**  
   点击"Submit new issue"

### 快速链接：

```bash
# Issue 1
https://github.com/llluchy/Agent-Automate/issues/new?labels=ai-proposed,enhancement,testing&title=[AI提议]%20添加测试框架和单元测试

# Issue 2
https://github.com/llluchy/Agent-Automate/issues/new?labels=ai-proposed,enhancement,reliability&title=[AI提议]%20实现配置验证和错误处理机制

# Issue 3
https://github.com/llluchy/Agent-Automate/issues/new?labels=ai-proposed,enhancement,implementation&title=[AI提议]%20实现自动化处理脚本的代码实现

# Issue 4
https://github.com/llluchy/Agent-Automate/issues/new?labels=ai-proposed,enhancement,ci-cd&title=[AI提议]%20改进GitHub%20Actions工作流并添加通知机制

# Issue 5
https://github.com/llluchy/Agent-Automate/issues/new?labels=ai-proposed,documentation,user-experience&title=[AI提议]%20添加快速开始示例和模板项目
```

---

## 🔧 故障排除

### 问题：gh CLI报错 "403: Resource not accessible"

**原因**: GitHub token没有写权限

**解决**:
1. 使用选项5导出文件
2. 手动创建Issues
3. 或者更新GitHub token权限：
   ```bash
   gh auth refresh -h github.com -s repo
   ```

### 问题：脚本找不到 proposed-issues.md

**原因**: 文件不存在或路径错误

**解决**:
```bash
# 确保在项目根目录
cd /path/to/Agent-Automate

# 拉取最新代码
git pull

# 检查文件
ls .cursor/proposed-issues.md

# 运行脚本
./scripts/create-issues-helper.sh
```

### 问题：没有安装 gh CLI

**解决方案1**: 安装gh CLI
```bash
# macOS
brew install gh

# Ubuntu/Debian
sudo apt install gh

# 其他: https://github.com/cli/cli#installation
```

**解决方案2**: 使用导出功能
```bash
./scripts/create-issues-helper.sh
# 选择: 5
# 然后手动创建
```

---

## 📚 相关文档

- `.cursor/proposed-issues.md` - 完整的Issues详细内容
- `.cursor/issues-summary.md` - Issues摘要和快速参考
- `START_HERE.md` - 项目快速开始指南

---

## 💡 最佳实践

1. **先阅读再创建**  
   先查看 `.cursor/issues-summary.md` 了解概览

2. **分批创建**  
   可以先创建高优先级的，评估后再创建其他

3. **调整内容**  
   使用导出功能，可以在创建前修改内容

4. **添加上下文**  
   创建Issue时可以添加项目特定的补充信息

---

## 🤝 贡献

如果您有改进建议或发现bug：
1. 创建Issue
2. 提交Pull Request
3. 或联系项目维护者

---

**更新时间**: 2026-11-05  
**版本**: v1.0
