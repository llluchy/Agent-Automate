#!/bin/bash

# AI分析Issues创建助手
# 此脚本帮助从proposed-issues.md提取内容创建GitHub Issues

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ISSUES_FILE="$SCRIPT_DIR/../.cursor/proposed-issues.md"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  AI提议Issues创建助手${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查文件是否存在
if [ ! -f "$ISSUES_FILE" ]; then
    echo -e "${RED}❌ 错误: 找不到 proposed-issues.md${NC}"
    echo "请确保文件位于: $ISSUES_FILE"
    exit 1
fi

echo -e "${GREEN}✅ 找到Issues文档${NC}"
echo ""

# 定义Issue信息
declare -a ISSUES
ISSUES[1]="添加测试框架和单元测试|ai-proposed,enhancement,testing|高"
ISSUES[2]="实现配置验证和错误处理机制|ai-proposed,enhancement,reliability|高"
ISSUES[3]="实现自动化处理脚本的代码实现|ai-proposed,enhancement,implementation|中"
ISSUES[4]="改进GitHub Actions工作流并添加通知机制|ai-proposed,enhancement,ci-cd|中"
ISSUES[5]="添加快速开始示例和模板项目|ai-proposed,documentation,user-experience|中"

# 显示菜单
echo "请选择创建方式："
echo ""
echo "  1) 创建所有5个Issues"
echo "  2) 只创建高优先级Issues（#1, #2）"
echo "  3) 选择性创建单个Issue"
echo "  4) 显示创建命令（手动复制执行）"
echo "  5) 导出Issue内容到文件"
echo "  0) 退出"
echo ""
read -p "请选择 [0-5]: " choice

case $choice in
    1)
        echo ""
        echo -e "${YELLOW}准备创建所有5个Issues...${NC}"
        for i in {1..5}; do
            create_issue $i
        done
        ;;
    2)
        echo ""
        echo -e "${YELLOW}准备创建高优先级Issues...${NC}"
        create_issue 1
        create_issue 2
        ;;
    3)
        echo ""
        echo "可用的Issues："
        for i in {1..5}; do
            IFS='|' read -r title labels priority <<< "${ISSUES[$i]}"
            echo "  $i) [优先级: $priority] $title"
        done
        echo ""
        read -p "选择Issue编号 [1-5]: " issue_num
        if [ "$issue_num" -ge 1 ] && [ "$issue_num" -le 5 ]; then
            create_issue $issue_num
        else
            echo -e "${RED}❌ 无效的选择${NC}"
            exit 1
        fi
        ;;
    4)
        echo ""
        echo -e "${YELLOW}以下是创建命令，您可以复制执行：${NC}"
        echo ""
        show_commands
        ;;
    5)
        echo ""
        export_issues
        ;;
    0)
        echo "退出"
        exit 0
        ;;
    *)
        echo -e "${RED}❌ 无效的选择${NC}"
        exit 1
        ;;
esac

# 函数：创建Issue
create_issue() {
    local issue_num=$1
    IFS='|' read -r title labels priority <<< "${ISSUES[$issue_num]}"
    
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}创建Issue #$issue_num: $title${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # 提取Issue内容
    local start_marker="## Issue $issue_num:"
    local end_marker="## Issue $((issue_num + 1)):"
    if [ $issue_num -eq 5 ]; then
        end_marker="## 总结"
    fi
    
    local temp_file=$(mktemp)
    sed -n "/${start_marker}/,/${end_marker}/p" "$ISSUES_FILE" | head -n -1 > "$temp_file"
    
    # 尝试使用gh CLI创建
    if command -v gh &> /dev/null; then
        echo "使用GitHub CLI创建Issue..."
        
        if gh issue create \
            --title "[AI提议] $title" \
            --body-file "$temp_file" \
            --label "$labels" 2>&1; then
            echo -e "${GREEN}✅ Issue #$issue_num 创建成功${NC}"
        else
            echo -e "${YELLOW}⚠️  GitHub CLI创建失败（可能是权限问题）${NC}"
            echo ""
            echo "请手动创建Issue："
            echo "1. 访问: https://github.com/llluchy/Agent-Automate/issues/new"
            echo "2. 标题: [AI提议] $title"
            echo "3. 内容已保存到: $temp_file"
            echo "4. 标签: $labels"
            echo ""
            read -p "按回车继续..."
        fi
    else
        echo -e "${YELLOW}⚠️  未安装GitHub CLI${NC}"
        echo ""
        echo "请手动创建Issue："
        echo "标题: [AI提议] $title"
        echo "标签: $labels"
        echo "内容: 见 $temp_file"
    fi
    
    rm -f "$temp_file"
}

# 函数：显示创建命令
show_commands() {
    for i in {1..5}; do
        IFS='|' read -r title labels priority <<< "${ISSUES[$i]}"
        echo "# Issue $i: $title"
        echo "gh issue create \\"
        echo "  --title '[AI提议] $title' \\"
        echo "  --body-file <(sed -n '/## Issue $i:/,/## Issue $((i+1)):/p' .cursor/proposed-issues.md | head -n -1) \\"
        echo "  --label '$labels'"
        echo ""
    done
}

# 函数：导出Issues
export_issues() {
    local output_dir="$SCRIPT_DIR/../.cursor/issues-export"
    mkdir -p "$output_dir"
    
    echo -e "${YELLOW}导出Issues到单独文件...${NC}"
    
    for i in {1..5}; do
        IFS='|' read -r title labels priority <<< "${ISSUES[$i]}"
        local output_file="$output_dir/issue-$i.md"
        
        local start_marker="## Issue $i:"
        local end_marker="## Issue $((i + 1)):"
        if [ $i -eq 5 ]; then
            end_marker="## 总结"
        fi
        
        # 添加标题和元数据
        cat > "$output_file" << EOF
# [AI提议] $title

**优先级**: $priority  
**标签**: $labels

---

EOF
        
        # 添加内容
        sed -n "/${start_marker}/,/${end_marker}/p" "$ISSUES_FILE" | head -n -1 >> "$output_file"
        
        echo -e "${GREEN}✅ 导出: $output_file${NC}"
    done
    
    echo ""
    echo -e "${GREEN}✅ 所有Issues已导出到: $output_dir${NC}"
    echo ""
    echo "您可以："
    echo "1. 查看每个文件的内容"
    echo "2. 手动复制到GitHub Issues"
    echo "3. 或使用文件内容作为模板"
}

echo ""
echo -e "${GREEN}完成！${NC}"
