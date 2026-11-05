# Cursor Environment 配置说明

## 什么是Environment？

Environment是Cursor Cloud Agent的运行环境，包含：
- 预安装的依赖（npm/pip packages等）
- 启动脚本（start scripts）
- 环境变量
- Docker等服务配置

## 如何获取Environment名称

1. **访问Cursor Dashboard**
   ```
   https://cursor.com/dashboard/cloud-agents#environments
   ```

2. **查看你的Environments列表**
   - Personal Environments：个人环境
   - Team Environments：团队环境

3. **复制Environment名称**
   - 点击Environment查看详情
   - 名称通常类似：`my-project-env`

## 配置步骤

### 方式一：使用默认环境（推荐）

在`.cursor/config.json`中保持：
```json
{
  "cursor": {
    "environment": {
      "enabled": false
    }
  }
}
```

Agent将使用Cursor的默认云环境，自动安装依赖。

### 方式二：使用自定义环境

1. **在Cursor Dashboard创建Environment**
   - 设置repository
   - 配置install命令（如`npm install`）
   - 配置start命令（如`npm run dev`）

2. **更新`.cursor/config.json`**
   ```json
   {
     "cursor": {
       "environment": {
         "enabled": true,
         "type": "cloud",
         "name": "your-environment-name"
       }
     }
   }
   ```

3. **提交并推送配置**
   ```bash
   git add .cursor/config.json
   git commit -m "配置Cursor Environment"
   git push
   ```

## Environment类型

- **`cloud`**：Cursor托管的云环境（最常用）
- **`pool`**：自托管的worker pool（企业用户）

## 注意事项

- **Environment名称区分大小写**
- **启用environment时，repository由environment自动提供，无需在API中指定**
- 不配置environment时使用默认云环境（推荐新项目）
- 复杂项目建议创建专属environment预装依赖

## API规则

**⚠️ 重要：`env.name` 与 `repos` 互斥**

- `enabled: true` → 只传 `env`，Environment自带repository配置
- `enabled: false` → 只传 `repos`，使用默认环境
