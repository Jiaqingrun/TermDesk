# TermDesk

macOS 个人终端控制台：菜单栏 + 悬浮窗 + QR / 系统 / Shell / 外接屏联动。

## 克隆（与 SysPeek 同级）

TermDesk 通过 SPM 本地路径依赖 `../syspeek`，请保持同级目录：

```bash
mkdir -p ~/QR/dev && cd ~/QR/dev
git clone https://github.com/Jiaqingrun/SysPeek.git syspeek
git clone https://github.com/Jiaqingrun/TermDesk.git term-desk
cd term-desk
swift build -c release
.build/release/TermDesk
```

## 运行（本机已有仓库）

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

- **SysPeek**（同级目录 `../syspeek`，[GitHub](https://github.com/Jiaqingrun/SysPeek)）：提供 QRMetricsKit / SysPeekShared；运行 SysPeek 时可读 `widget-snapshot.json`，避免双份采样
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
