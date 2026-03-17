<div align="center">

# 🎯 GitHub Development Standard

**AI 辅助开发的工程规范 — 让代码质量不再妥协**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Stars](https://img.shields.io/github/stars/SonicBotMan/github-development-standard.svg)](https://github.com/SonicBotMan/github-development-standard)
[![Skill Version](https://img.shields.io/badge/Skill-v2.0-blue.svg)](./Skill.md)

**中文** | [English](README_EN.md)

</div>

已发布到 ClawHub，支持一键安装：https://clawhub.ai/SonicBotMan/github-development-standard

---

## 💔 一个真实的故事

**背景：** 小团队，预算有限，用 GLM-4-Flash 做代码开发

**22:30 — 模型回复：**
> ✅ 已修复 Bug #56，summary 变量覆盖问题已解决

**第二天 09:00 — 团队发现：**
- ❌ 改动量：247 行（预期 20 行）
- ❌ 夹带私货：顺便重构了 3 个函数
- ❌ 无验证：连语法检查都没做
- ❌ 旧功能崩了：核心流程跑不通

**结果：** 生产环境崩溃、加班到凌晨 3 点、当月预算超支 40%。

**引入本规范后，3 个月：**
- 📉 Bug 修复返工率：60% → **5%**
- 📈 代码审查时间：30 分钟 → **5 分钟**
- 💰 模型调用成本降低 **40%**（不再返工）

---

## 🚨 AI 生成项目的 6 个高频陷阱（v2.0 新增）

> 来自对真实 AI 生成项目（lobster-press / openclaw-portable / smart-search-fusion）的代码审查，原版规范一条都没涉及。

| # | 陷阱 | 典型现象 | 30秒检查命令 |
|---|------|----------|------------|
| 1 | **同一天发布多版本** | `v3.0/v2.5/v2.0` 全在同一天 | `git log --tags --oneline` |
| 2 | **Git 冲突标记被提交** | README 里有 `<<<<<<<` | `grep -r "<<<<<<" *.md` |
| 3 | **根目录文档爆炸** | `RELEASE_SUCCESS.md` 等临时文件 | `ls -1 \| grep -E "RELEASE_SUCCESS\|PUSH_TO_GITHUB"` |
| 4 | **下载链接版本号对不上** | 文本说 v6.0，链接指向 v5.1 | `grep -oE "releases/tag/v[0-9.]+" README*.md` |
| 5 | **无法证伪的「首次」声明** | 「世界首个...」 | 人工判断 |
| 6 | **配置路径文档与代码不一致** | 文档说 `config/`，代码读 `scripts/` | `grep -rn "CONFIG_FILE" scripts/` |

完整陷阱说明与修复命令 → [Skill.md](./Skill.md)

---

## 🛠️ 一键自检脚本（commit 前跑一遍）

```bash
# 下载并安装为 git hook（一次设置，永久生效）
curl -sO https://raw.githubusercontent.com/SonicBotMan/github-development-standard/master/scripts/pre-commit-check.sh
cp pre-commit-check.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

**自动检查：** Git 冲突标记 / 根目录冗余文件 / 下载链接版本一致性 / Python & Shell 语法

脚本源码：[scripts/pre-commit-check.sh](./scripts/pre-commit-check.sh)

---

## 📋 工具包内容

| 工具 | 说明 |
|------|------|
| **9 步开发流程** | 读 issue → 任务卡 → 基线 → 改动点 → 编码 → 验证 → diff → 发布 → 复盘 |
| **4 层验证** | 语法(1s) → 导入(1s) → 行为(5-30min) → 回归(5-30min) |
| **21 项验收清单** | A–D 共 15 项通用工程检查 + E 组 6 项 AI 专项检查（v2.0 新增）|
| **8 条编码纪律** | 禁止夹带私货、禁止凭记忆重写、禁止边修 bug 边重构… |
| **一键自检脚本** | commit 前自动拦截高频 AI 陷阱（v2.0 新增）|

> ⚠️ 验收清单有 1 项答不上来 → 不发布

---

## 🚀 快速开始

```bash
# 克隆
git clone https://github.com/SonicBotMan/github-development-standard.git
cd github-development-standard

# 在你的项目里安装自检脚本
bash scripts/install-hook.sh
```

**每次开发任务：执行 9 步流程 → 发布前过 21 项清单。**

---

## 📚 文档目录

| 文档 | 说明 |
|------|------|
| [Skill.md](./Skill.md) | 完整规范（AI 可直接加载）|
| [docs/workflow.md](./docs/workflow.md) | 9 步流程详解 |
| [docs/validation.md](./docs/validation.md) | 4 层验证详解 |
| [docs/checklist.md](./docs/checklist.md) | 21 项清单（打印版）|
| [examples/lobster-press-bugfix.md](./examples/lobster-press-bugfix.md) | 真实修复案例 |
| [templates/任务卡片模板.md](./templates/任务卡片模板.md) | 任务卡片模板 |

---

## 📊 效果对比

| 指标 | 无规范 | 有规范 |
|------|:------:|:------:|
| Bug 修复返工率 | 60% | **5%** |
| 平均改动量 | 200+ 行 | **15 行** |
| 夹带私货率 | 70% | **0%** |
| 合并冲突残留 | 常见 | **0%** |
| 根目录冗余文档 | 常见 | **0%** |
| 下载链接错误 | 偶发 | **0%** |

---

## 📌 版本历史

| 版本 | 日期 | 要点 |
|------|------|------|
| **v2.0** | 2026-03-18 | 新增 6 大 AI 陷阱、E 组验收清单、一键自检脚本（Claude Sonnet 4.6 优化）|
| v1.0 | 2026-03-13 | 初始版本：9 步流程 + 4 层验证 + 15 项清单 |

---

## 🤝 贡献 & 许可证

欢迎贡献！请查看 [CONTRIBUTING.md](./CONTRIBUTING.md)。[MIT License](./LICENSE)

---

## 🙏 致谢

- **原始版本**：SonicBotMan Team（基于真实创业团队踩坑经历）
- **v2.0 优化**：Claude Sonnet 4.6（基于对 lobster-press / openclaw-portable / smart-search-fusion 的实际代码审查）

---

> **流程 > 模型能力。相信流程，不相信「修好了」。** 💪

**Made with ❤️ by SonicBotMan Team + Claude Sonnet 4.6**
