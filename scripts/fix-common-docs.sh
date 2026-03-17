#!/bin/bash

# 快速修复常见文档问题 - 基于实战经验
# ⚠️ 警告：此脚本会修改文件，请先提交当前更改

set -e

echo "🔧 GitHub Development Standard - 快速修复工具"
echo "================================================"
echo ""
echo "⚠️  警告：此脚本会修改文件，建议先提交当前更改"
echo ""
read -p "是否继续？(y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "已取消"
    exit 0
fi

FIXED=0

# 1. 删除合并冲突标记（保留第一个版本）
echo ""
echo "### 1. 清理合并冲突标记"
echo ""
for file in README*.md; do
    if [ -f "$file" ] && grep -q "<<<<<<\|>>>>>>\|======" "$file" 2>/dev/null; then
        echo "修复 $file 中的合并冲突标记..."
        # 使用 awk 处理合并冲突
        awk '
        /^<<<<<<</ { in_conflict=1; next }
        /^=======/ { in_conflict=2; next }
        /^>>>>>>>/ { in_conflict=0; next }
        in_conflict==1 { print }
        in_conflict!=2 { if (in_conflict!=1) print }
        ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
        FIXED=$((FIXED + 1))
    fi
done

if [ $FIXED -eq 0 ]; then
    echo "✅ 未发现合并冲突标记"
else
    echo "✅ 已修复 $FIXED 个文件的合并冲突标记"
fi

# 2. 删除常见冗余文件
echo ""
echo "### 2. 清理冗余文件"
echo ""
REDUNDANT_FILES=(
    "DUAL_RELEASE_SUMMARY.md"
    "STAR_HISTORY_FIX.md"
    "RELEASE_NOTES_v*.md"
    "README_V5.md"
    "DOWNLOAD_INSTRUCTIONS.md"
)

DELETED=0
for pattern in "${REDUNDANT_FILES[@]}"; do
    for file in $pattern; do
        if [ -f "$file" ]; then
            echo "删除冗余文件: $file"
            rm -f "$file"
            DELETED=$((DELETED + 1))
        fi
    done
done

if [ $DELETED -eq 0 ]; then
    echo "✅ 未发现冗余文件"
else
    echo "✅ 已删除 $DELETED 个冗余文件"
    echo ""
    echo "💡 提示：请检查是否有有价值的内容需要合并到 CHANGELOG.md"
fi

# 3. 提示检查版本号
echo ""
echo "### 3. 检查版本号一致性"
echo ""
VERSION_LINKS=$(grep -o "releases/tag/v[0-9.]*)" README*.md 2>/dev/null | sort | uniq -c | awk '$1 > 1 {print $0}' || true)
if [ -n "$VERSION_LINKS" ]; then
    echo "⚠️  发现版本号不一致："
    echo "$VERSION_LINKS"
    echo ""
    echo "请手动检查并修复版本号"
else
    echo "✅ 版本号一致"
fi

# 总结
echo ""
echo "================================================"
echo "📊 修复结果"
echo "================================================"
echo "修复的文件: $FIXED"
echo "删除的文件: $DELETED"
echo ""
if [ $FIXED -gt 0 ] || [ $DELETED -gt 0 ]; then
    echo "✅ 已完成修复，请检查更改："
    echo "   git diff"
    echo "   git status"
    echo ""
    echo "确认无误后提交："
    echo "   git add -A"
    echo "   git commit -m 'fix: clean up documentation issues'"
else
    echo "✅ 未发现需要修复的问题"
fi
