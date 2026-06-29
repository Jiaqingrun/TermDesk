# TermDesk

macOS 个人终端控制台：菜单栏 + 悬浮窗 + QR / 系统 / Shell / 外接屏联动。

## 运行

```bash
cd ~/QR/dev/term-desk
swift build -c release
.build/release/TermDesk
```

## 快捷键

| 操作 | 按键 |
|------|------|
| 悬浮控制台 | `⌘⇧\`` |
| 菜单栏面板 | 点击菜单栏终端图标 |

## 依赖

- SysPeek（可选）：运行时可读 `widget-snapshot.json`，避免双份采样
- `qr` CLI：QR Tab 与 Shell chips
- mac-dashboard-agent（可选）：Fleet Tab 与 Pi 推送

## 数据

| 路径 | 内容 |
|------|------|
| `~/Library/Application Support/TermDesk/snapshot.json` | 统一快照（agent 读取） |
| `~/Library/Application Support/TermDesk/fleet-status.json` | Pi 推送状态 |

业务数据 **不** 写入 `qr.db`。

## 架构

见 [DESIGN.md](./DESIGN.md)。
