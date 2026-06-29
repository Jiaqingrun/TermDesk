# 项目约定 · TermDesk

## 用途

macOS **个人终端控制台**：终端审美 + 多面展示（菜单栏 / 悬浮窗 / 外接屏），整合系统指标、QR 脉搏、迷你 Shell 与 Pi Fleet 状态。

## 命题

把「系统在忙什么、QR 是否健康、常用命令、Pi 是否在线」收进同一套终端风 UI；**不是** iTerm 替代品。

## MVP 范围（v0.2）

- [x] v0.1 全部功能
- [x] `TermDesk.app` 打包脚本（`scripts/package-app.sh`）
- [x] 登录项（SMAppService）
- [x] 精简菜单栏模式 + 优先 SysPeek 采样开关
- [x] 自绘菜单栏终端图标
- [x] `scripts/self-check.sh` 自检

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

- 构建：`./scripts/package-app.sh` → `open TermDesk.app`
- 调试：`swift build -c release && .build/release/TermDesk`
- 自检：`./scripts/self-check.sh`
- **架构图解**：[DESIGN.md](./DESIGN.md)；规范见 `~/QR/experiments/idea/docs/DIAGRAM-STANDARDS.md`

## AI 协作

1. **Cursor 工作区**：`~/QR/dev/term-desk`，QR 项目键 `dev/term-desk`
2. **会话开始**：`PROJECT.md` → `DESIGN.md` → `README.md`
3. 架构决策：`qr log --type decision`；检索 `project: "dev/term-desk"`

## 当前阶段

**v0.2** — 可打包 App、登录项、精简菜单栏、SysPeek 优先采样、菜单栏自绘图标。
