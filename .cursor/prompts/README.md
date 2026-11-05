# Cursor Agent Prompts

此目录存放触发Cursor Agent时使用的prompt模板。

## 文件说明

- `daily-scan.txt` - 每日自动扫描时的任务指令
- `issue-develop.txt` - Issue开发触发时的任务指令

## 变量替换

在`issue-develop.txt`中可使用变量：
- `{{ISSUE_NUMBER}}` - 自动替换为触发的Issue编号

## 自定义

复制此项目到新仓库后，只需修改这些txt文件，无需改动workflow。
