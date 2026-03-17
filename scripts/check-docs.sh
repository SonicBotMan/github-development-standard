#!/bin/bash

# 文档检查工具 - 基于实战经验总结
# 用于检查常见文档问题

set -e

echo "🔍 GitHub Development Standard - 文档检查工具"
echo "=============================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# 1. 检查合并冲突标记
echo "### 1. 检查合并冲突标记"
echo ""
if grep -r "<<<<<<\|>>>>>>\|======" *.md 2>/dev/null; then
    echo -e "${RED}❌ 发现合并冲突标记${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✅ 无冲突标记${NC}"
fi
echo ""

# 2. 检查冗余文件
echo "### 2. 检查冗余文件"
echo ""
REDUNDANT_FILES=$(ls -1 2>/dev/null | grep -E "DUAL_RELEASE|STAR_HISTORY|RELEASE_NOTES|README_V5|DOWNLOAD_INSTRUCTIONS" || true)
if [ -n "$REDUNDANT_FILES" ]; then
    echo -e "${RED}❌ 发现冗余文件:${NC}"
    echo "$REDUNDANT_FILES"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✅ 无冗余文件${NC}"
fi
echo ""

# 3. 检查版本号一致性
echo "### 3. 检查版本号一致性"
echo ""
VERSION_LINKS=$(grep -o "releases/tag/v[0-9.]*)" README*.md 2>/dev/null | sort | uniq -c | awk '$1 > 1 {print $0}' || true)
if [ -n "$VERSION_LINKS" ]; then
    echo -e "${YELLOW}⚠️  版本号不一致:${NC}"
    echo "$VERSION_LINKS"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✅ 版本号一致${NC}"
fi
echo ""

# 4. 检查无法证伪的声明
echo "### 4. 检查无法证伪的声明"
echo ""
if grep -i "world's first\|世界首个\|全球首创" README*.md 2>/dev/null; then
    echo -e "${YELLOW}⚠️  发现无法证伪的声明（建议改为描述性标题）${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✅ 无无法证伪的声明${NC}"
fi
echo ""

# 5. 检查 README 文件数量
echo "### 5. 检查 README 文件数量"
echo ""
README_COUNT=$(ls -1 README*.md 2>/dev/null | wc -l)
if [ "$README_COUNT" -gt 5 ]; then
    echo -e "${YELLOW}⚠️  README 文件过多: $README_COUNT 个${NC}"
    ls -1 README*.md
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✅ README 文件数量正常: $README_COUNT 个${NC}"
fi
echo ""

# 总结
echo "=============================================="
echo "📊 检查结果"
echo "=============================================="
echo -e "错误: ${RED}$ERRORS${NC}"
echo -e "警告: ${YELLOW}$WARNINGS${NC}"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ 发现 $ERRORS 个错误，请修复后再提交${NC}"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  发现 $WARNINGS 个警告，建议修复${NC}"
    exit 0
else
    echo -e "${GREEN}✅ 所有检查通过！${NC}"
    exit 0
fi
