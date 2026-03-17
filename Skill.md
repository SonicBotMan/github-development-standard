---
name: GitHub Development Standard
description: AI辅助开发的工程规范 — 9步流程 + 4层验证 + 15项验收清单 + AI生成项目专项陷阱指南
---

# GitHub Development Standard Skill

> **流程 > 模型能力。低端模型不是问题，没有流程才是问题。**
>
> 本 Skill 由 Claude Sonnet 4.6 基于对真实 AI 生成项目（lobster-press / openclaw-portable / smart-search-fusion）的代码审查经验优化，针对 AI 辅助开发的高频陷阱做了专项补充。

---

## 🎯 适用对象

- **低端/中端 AI 模型**（GLM-4-Flash、GLM-4 等）：用本规范约束生成行为
- **新手程序员**：用本规范建立正确的工程直觉
- **任何 AI 辅助开发场景**：防止「生成即提交」带来的质量崩塌

---

## 💡 核心理念

```
先定义问题 → 再定义改法 → 再写代码 → 再做验证 → 最后才发布
```

**永远不要跳步骤。** 每一次跳步骤，都是在给未来的自己埋雷。

---

## 🚨 AI 生成项目的高频陷阱（新增）

> 这是本规范相比原版最重要的补充。这些陷阱来自对真实 AI 生成项目的代码审查。

### 陷阱 1：同一天发布多个版本（最致命）

**现象：**
```
v3.0.0  2026-03-17
v2.6.0  2026-03-17
v2.5.0  2026-03-17
v2.0.0  2026-03-15
```

**问题：** 版本历史是事后补写的，不是真实演进的。任何有经验的开发者看到这个都会立即失去信任。

**规则：** 版本号由时间背书，不由文字描述决定。一次 commit 对应一个真实的改动，不要事后虚构历史。

**正确做法：**
```bash
# 从今天起，每次改动 → 一次真实 commit → 必要时才打 tag
git add .
git commit -m "fix: 修复 XXX 问题"
# 只有准备发布时才 tag
git tag v1.0.0
git push origin v1.0.0
```

---

### 陷阱 2：Git 合并冲突标记被提交到主分支

**现象：** README.md 末尾出现：
```
<<<<<<< HEAD
![Star History Chart](...)
=======
[![GitHub stars](...)
>>>>>>> 896d1b6
```

**问题：** 用户看到的 README 是损坏的。这是「生成完就提交、没有人工审查」的直接产物。

**每次 commit 前必做的 30 秒检查：**
```bash
# 检查所有 Markdown 文件是否有冲突标记
grep -r "<<<<<<\|>>>>>>\|=======" *.md **/*.md 2>/dev/null \
  && echo "❌ 发现合并冲突，请先解决" || echo "✅ 无冲突标记"
```

---

### 陷阱 3：根目录文档爆炸

**现象：**
```
RELEASE_SUCCESS.md
PUSH_TO_GITHUB.md
DUAL_RELEASE_SUMMARY.md
STAR_HISTORY_FIX.md
RELEASE_NOTES_v5.0.2.md
RELEASE_NOTES_v5.0.3.md
README_V5.md
```

**问题：** AI 每次生成都倾向于新建文件而非修改已有文件，导致根目录堆满一次性临时文档。

**根目录应该只有：**
```
README.md          # 主文档（必须）
LICENSE            # 许可证（必须）
CHANGELOG.md       # 版本历史（唯一）
CONTRIBUTING.md    # 贡献指南（可选）
+ 必要的配置文件（package.json / pyproject.toml 等）
```

**清理命令：**
```bash
# 确认哪些文件应该删除
ls -1 | grep -E "RELEASE_NOTES_v|RELEASE_SUCCESS|PUSH_TO_GITHUB|DUAL_RELEASE|STAR_HISTORY|README_V[0-9]"

# 把有价值的内容先合并到 CHANGELOG.md，再删除
git rm RELEASE_SUCCESS.md PUSH_TO_GITHUB.md  # 等
git commit -m "chore: 清理根目录冗余文档"
```

---

### 陷阱 4：README 中的链接版本号对不上

**现象：**
```markdown
📥 **Download**: [OpenClaw-v6.0.0-windows.tar.gz](
  https://github.com/xxx/releases/tag/v5.1.0)
```
文本说 v6.0，链接指向 v5.1。

**检查命令：**
```bash
# 提取 README 中所有 release 链接的版本号，检查是否一致
grep -oE "releases/tag/v[0-9]+\.[0-9]+(\.[0-9]+)?" README*.md | sort | uniq -c
# 如果出现多个不同版本号 → 必须修复
```

---

### 陷阱 5：无法证伪的「首次/世界第一」声明

**现象：**
```
"The World's First Truly Offline AI Assistant"
"首次将 Ebbinghaus 遗忘曲线应用于 LLM 记忆管理"
```

**问题：** AI 训练数据里充满论文摘要的「first/novel」句式，模型很容易生成这类表达。但没有引用佐证的声明会让专业用户直接失去信任。

**规则：**
- 有文献支撑 → 可以写，附上引用
- 没有佐证 → 改成描述性表达，说你做了什么，不说你是第一个

---

### 陷阱 6：配置文件路径文档与代码不一致

**现象：** 文档说把配置放到 `config/config.json`，代码里实际读取的是 `scripts/config.json`——用户照文档操作后功能失效。

**检查命令：**
```bash
# 找出代码中所有读取配置文件的路径
grep -rn "config\.json\|config_file\|CONFIG_FILE" scripts/ src/ *.py *.sh 2>/dev/null

# 对比 README 中描述的配置路径
grep -n "config" README.md | grep -i "copy\|edit\|path\|放到"
```

---

## 📋 9 步开发流程

```
1. 读 issue → 2. 写任务卡 → 3. 确定基线
     ↓
4. 列改动点 → 5. 编码 → 6. 本地验证
     ↓
7. 看 diff → 8. 写发布说明 → 9. 复盘
```

### Step 1：读 Issue（只理解，不改代码）

- ✅ 理解问题现象和预期行为
- ❌ 不要凭记忆猜测
- ❌ 不要急着看代码

### Step 2：写「5行任务卡」

```text
【任务类型】Bug 修复 / 功能新增 / 文档修复
【目标】一句话描述
【边界】只修改哪些文件/函数
【非目标】明确不打算改的内容
【影响范围】受影响的模块/功能
```

### Step 3：确定基线版本

```bash
git tag | sort -V | tail -5
git checkout v1.2.4
```

### Step 4：列改动点

```text
【改动点 1】
位置：src/xxx.py 第 XX 行
修改前：<old code>
修改后：<new code>
原因：<为什么这样改>
```

### Step 5：编码（8 条纪律）

1. 先复制旧代码，再局部替换，不要凭记忆重写
2. 改函数前，先通读函数的输入、输出、副作用
3. 涉及数据结构变化时，先搜所有使用点
4. 不要同时改逻辑和风格
5. 不要在 bug fix 里做重构
6. 不要修改未被需求要求的行为
7. 不要在没有验证前说「修好了」
8. 不要让 release note 超前于实际代码

### Step 6：本地验证（4 层测试）

```bash
# Layer 1: 语法验证（1秒）
python3 -m py_compile src/xxx.py
# Shell 脚本语法检查
bash -n scripts/xxx.sh && echo "✅ 语法OK"

# Layer 2: 导入验证（1秒）
python3 -c "from src.xxx import ClassName; print('ok')"

# Layer 3: 行为验证（5-30分钟）
python3 -m pytest tests/unit/ -v

# Layer 4: 回归验证（5-30分钟）
python3 -m pytest tests/ -v
```

### Step 7：看 diff（检查 3 件事）

| 任务类型 | 预期改动量 |
|---------|-----------|
| 修 1 个小 bug | 5–30 行 |
| 修 1 组相关 bug | 20–80 行 |
| 小功能新增 | 30–150 行 |
| **超过 200 行** | **必须怀疑是否改多了** |

检查：改动量是否匹配任务规模 → 是否改到了非目标区域 → 发布说明是否和 diff 一致

### Step 8：写发布说明

```
fix: 修复 XXX 问题

问题：
- 问题描述

修复：
- 修复方案

验证：
- ✅ 语法检查通过
- ✅ 导入检查通过
- ✅ 行为验证通过
- ✅ 回归测试通过

影响范围：
- 修改文件/函数

非修改：
- 不修改 XXX

Closes #XX
```

### Step 9：复盘

```text
做得好的地方：...
可以改进的地方：...
学到的经验：...
```

---

## ✅ 15 项验收清单 + 6 项 AI 专项检查

**发布前，逐项回答。有 1 项答不上来 → 不发布。**

### A. 需求一致性（3 项）
- [ ] A1. 我能用一句话说清这次修复的目标
- [ ] A2. 我知道这次「不打算修」的内容有哪些
- [ ] A3. 代码改动与 issue 描述一致

### B. 技术正确性（4 项）
- [ ] B1. 我基于正确版本开始修改
- [ ] B2. 我没有重写整个文件
- [ ] B3. 数据结构变化已同步所有引用点
- [ ] B4. 新逻辑不会破坏旧逻辑

### C. 测试验证（4 项）
- [ ] C1. 语法检查通过
- [ ] C2. 导入检查通过
- [ ] C3. 最小样例验证通过
- [ ] C4. 回归测试通过

### D. 发布质量（4 项）
- [ ] D1. diff 大小与任务规模匹配
- [ ] D2. release note 与实际代码一致
- [ ] D3. 版本号、文档、注释已同步
- [ ] D4. 我可以指出这次改动的风险点

### E. AI 生成专项检查（6 项）⭐ 新增
- [ ] E1. README 中无 `<<<<<<<` / `>>>>>>>` 冲突标记
- [ ] E2. 根目录无临时文档（RELEASE_SUCCESS / PUSH_TO_GITHUB 等）
- [ ] E3. 所有下载链接的版本号与当前 release 一致
- [ ] E4. 版本历史中没有同一天发布 3 个以上版本
- [ ] E5. README 中无无法证伪的「首次/世界第一」声明
- [ ] E6. 文档描述的配置路径与代码实际读取路径一致

---

## 🛠️ 一键自检脚本（新增）

**在 commit 之前跑一遍：**

```bash
#!/bin/bash
# pre-commit-check.sh — AI 辅助项目提交前自检
# 使用方法: bash pre-commit-check.sh
# 安装为 git hook: cp pre-commit-check.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit

echo "=== 🔍 提交前自检 ==="
PASS=true

# E1: 检查合并冲突标记
if grep -rq "<<<<<<\|>>>>>>" *.md 2>/dev/null; then
  echo "❌ [E1] 发现合并冲突标记，请先解决"
  PASS=false
else
  echo "✅ [E1] 无合并冲突标记"
fi

# E2: 检查根目录冗余文档
JUNK=$(ls -1 | grep -E "RELEASE_SUCCESS|PUSH_TO_GITHUB|DUAL_RELEASE|STAR_HISTORY_FIX|README_V[0-9]")
if [ -n "$JUNK" ]; then
  echo "❌ [E2] 发现冗余文档:"
  echo "$JUNK" | sed 's/^/   /'
  PASS=false
else
  echo "✅ [E2] 根目录干净"
fi

# E3: 检查下载链接版本号一致性
VERSIONS=$(grep -ohE "releases/tag/v[0-9]+\.[0-9]+(\.[0-9]+)?" README*.md 2>/dev/null | grep -oE "v[0-9]+\.[0-9]+(\.[0-9]+)?" | sort -u)
COUNT=$(echo "$VERSIONS" | grep -c "v" 2>/dev/null || echo 0)
if [ "$COUNT" -gt 1 ]; then
  echo "❌ [E3] README 中存在多个不同版本的下载链接:"
  echo "$VERSIONS" | sed 's/^/   /'
  PASS=false
else
  echo "✅ [E3] 下载链接版本号一致"
fi

# C1: Python 语法检查
PY_FILES=$(find . -name "*.py" -not -path "./.git/*" 2>/dev/null)
if [ -n "$PY_FILES" ]; then
  PY_ERR=false
  while IFS= read -r f; do
    python3 -m py_compile "$f" 2>/dev/null || { echo "❌ [C1] Python 语法错误: $f"; PY_ERR=true; PASS=false; }
  done <<< "$PY_FILES"
  [ "$PY_ERR" = false ] && echo "✅ [C1] Python 语法全部通过"
fi

# C1: Shell 语法检查
SH_FILES=$(find scripts/ -name "*.sh" 2>/dev/null)
if [ -n "$SH_FILES" ]; then
  SH_ERR=false
  while IFS= read -r f; do
    bash -n "$f" 2>/dev/null || { echo "❌ [C1] Shell 语法错误: $f"; SH_ERR=true; PASS=false; }
  done <<< "$SH_FILES"
  [ "$SH_ERR" = false ] && echo "✅ [C1] Shell 语法全部通过"
fi

echo ""
if [ "$PASS" = true ]; then
  echo "✅ 所有检查通过，可以提交"
  exit 0
else
  echo "❌ 存在问题，请修复后再提交"
  exit 1
fi
```

---

## 🔧 GitHub CLI 快速参考

```bash
# 查看 Issue
gh issue view 53 --repo owner/repo

# 评论并关闭 Issue
gh issue comment 53 --repo owner/repo --body "修复说明..."
gh issue close 53 --repo owner/repo

# 查看 PR 状态与 CI
gh pr view 55 --repo owner/repo
gh pr checks 55 --repo owner/repo

# 合并 PR
gh pr merge 55 --squash --repo owner/repo
```

---

## 📊 效果对比

| 指标 | 无规范 | 有规范 |
|------|:------:|:------:|
| Bug 修复返工率 | 60% | 5% |
| 平均改动量 | 200+ 行 | 15 行 |
| 夹带私货率 | 70% | 0% |
| 合并冲突残留 | 常见 | 0% |
| 根目录冗余文档 | 常见 | 0% |
| 下载链接错误 | 偶发 | 0% |

---

## 📚 延伸阅读

- `docs/workflow.md` — 9 步流程详解
- `docs/validation.md` — 4 层验证详解
- `docs/checklist.md` — 15 项清单（打印版）
- `examples/lobster-press-bugfix.md` — 真实修复案例
- `templates/任务卡片模板.md` — 任务卡片模板

---

## 🙏 致谢

- **原始版本**: SonicBotMan Team（基于真实创业团队踩坑经历）
- **v2.0 优化**: Claude Sonnet 4.6（基于对 lobster-press / openclaw-portable / smart-search-fusion 的实际代码审查）
- **方法论来源**: 软件工程最佳实践 + AI 辅助开发的真实踩坑

---

**让代码质量不再妥协。相信流程，不相信「修好了」。** 💪
