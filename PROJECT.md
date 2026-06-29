# 项目约定 · TermDesk

## 用途

macOS **个人终端控制台**：终端审美 + 多面展示（菜单栏 / 悬浮窗 / 外接屏），整合系统指标、QR 脉搏、迷你 Shell 与 Pi Fleet 状态。

## 命题

把「系统在忙什么、QR 是否健康、常用命令、Pi 是否在线」收进同一套终端风 UI；**不是** iTerm 替代品。

## MVP 范围（v0.1）

- [x] MenuBarExtra 四 Tab 面板（SYS / QR / SHELL / FLEET）
- [x] 优先读 SysPeek widget JSON，过期时 QRMetricsKit 本地采样
- [x] QR Tab：`qr doctor` 摘要 + `~/.qr/notes` 最近条目
- [x] 悬浮 NSPanel + 全局热键 `⌘⇧\``
- [x] SwiftTerm 迷你 Shell + qr 命令 chips
- [x] `snapshot.json` 供 mac-dashboard-agent 合并推送
- [x] QRMetricsKit 与 SysPeek 共享指标内核

## 技术栈

- Swift 5.9+ · SwiftUI + AppKit NSPanel
- 依赖：`../syspeek`（SysPeekShared + QRMetricsKit）、SwiftTerm
- 配置：`UserDefaults`；快照 `~/Library/Application Support/TermDesk/`

## 交互规格

| 项 | 规格 |
|----|------|
| 菜单栏 | 终端图标 · 380×自适应 popover |
| 悬浮窗 | 440×520 · 半透明 · 可拖动 |
| 热键 | `⌘⇧\`` |
| 刷新 | 面板关 8s / 开 0.5s；QR 30s |

## 与姊妹项目

| 项目 | 关系 |
|------|------|
| SysPeek | 共享 QRMetricsKit；菜单栏三柱仍由 SysPeek 负责；设置中可跳转 TermDesk |
| drip-ball | 并存，不抢 `⌘D` |
| mac-dashboard-agent | 读 `snapshot.json`，写 `fleet-status.json` |

## 开发约定

- 构建：`swift build -c release`
- 调试：`.build/release/TermDesk`
- **架构图解**：[DESIGN.md](./DESIGN.md)；规范见 `~/QR/experiments/idea/docs/DIAGRAM-STANDARDS.md`

## AI 协作

1. **Cursor 工作区**：`~/QR/dev/term-desk`，QR 项目键 `dev/term-desk`
2. **会话开始**：`PROJECT.md` → `DESIGN.md` → `README.md`
3. 架构决策：`qr log --type decision`；检索 `project: "dev/term-desk"`

## 当前阶段

**v0.1 · Phase 0–4 完成** — 脚手架、四 Tab、悬浮 Shell、Fleet 联动、QRMetricsKit 抽取。
