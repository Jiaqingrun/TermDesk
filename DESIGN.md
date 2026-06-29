# TermDesk · 设计文档

> macOS 个人终端控制台。图解规范见 `~/QR/experiments/idea/docs/DIAGRAM-STANDARDS.md`。

---

## 概念图

```mermaid
flowchart TB
    subgraph UI["表现层"]
        MBE[MenuBarExtra]
        FLOAT[FloatingPanel NSPanel]
        DASH[DashboardView 四 Tab]
        SHELL[ShellTab SwiftTerm]
    end

    subgraph Core["核心层"]
        STORE[TermDeskStore]
        BUS[TermDeskSnapshot JSON]
        RP[TermDeskRefreshPolicy]
    end

    subgraph Bridges["桥接层"]
        SYSB[SysSnapshotBridge]
        QRB[QRBridge]
        FLEET[FleetBridge]
    end

    subgraph Shared["共享依赖"]
        WIDGET[SysPeek widget JSON]
        KIT[QRMetricsKit]
        AGENT[mac-dashboard-agent]
    end

    MBE --> DASH
    FLOAT --> DASH
    DASH --> SHELL
    DASH --> STORE
    STORE --> RP --> SYSB & QRB & FLEET
    SYSB --> WIDGET & KIT
    QRB --> QRCLI[qr CLI / notes]
    STORE --> BUS
    BUS --> AGENT
    AGENT --> FLEET
```

**边界**：监控采样、Shell 输出、面板布局 **不** 写入 `qr.db`。

---

## 流程图

```mermaid
flowchart TD
    Start([启动 TermDesk]) --> Loop[TermDeskStore.runLoop]
    Loop --> Widget{SysPeek JSON 新鲜?}
    Widget -->|是| SysRead[读 WidgetSnapshot]
    Widget -->|否| Sample[QRMetricsKit.sample]
    SysRead --> Merge[合成 TermDeskSnapshot]
    Sample --> Merge
    Merge --> QR{距上次 QR 刷新 > 30s?}
    QR -->|是| QRLoad[QRBridge.load]
    QR -->|否| Fleet[FleetBridge.load]
    QRLoad --> Fleet
    Fleet --> Write[写 snapshot.json]
    Write --> UI[刷新 MenuBar / 悬浮窗]
    UI --> Hotkey{⌘⇧` ?}
    Hotkey -->|是| Toggle[FloatingPanel 切换]
    Hotkey -->|否| Loop
    Toggle --> Loop
```

---

## 思维导图

```mermaid
mindmap
  root((TermDesk))
    SYS
      读 SysPeek JSON
      过期 QRMetricsKit 采样
      P/E 内存 Ollama 卷
    QR
      qr doctor 摘要
      notes 最近 5 条
      打开 Web 8765
    SHELL
      SwiftTerm PTY
      chips doctor usage log
    FLEET
      agent config.yaml
      fleet-status.json
      Pi 在线态
    体验
      菜单栏 popover
      悬浮窗 半透明
      终端 bracket 标题
    不做
      完整 iTerm
      云同步
      drip-ball 合并
      qr.db 写入采样
```

---

## TermDeskSnapshot Schema

```json
{
  "updatedAt": "ISO8601",
  "sys": {
    "source": "SysPeek | TermDesk",
    "pCoreLoad": 0,
    "eCoreLoad": 0,
    "memoryPressure": "normal",
    "gpuActivity": "idle",
    "foregroundApp": "Cursor",
    "ollamaOnline": true,
    "ollamaModels": ["llama3"],
    "volumes": [{ "name": "TF", "connected": true, "freePercent": 42 }]
  },
  "qr": {
    "doctorOK": false,
    "issueCount": 4,
    "doctorLines": ["✓ ..."],
    "recentNotes": [{ "id": "x.md", "title": "...", "modifiedAt": "...", "preview": "..." }]
  },
  "fleet": {
    "agentConfigured": true,
    "lastPushAt": 1710000000,
    "lastPushChannel": "tailscale",
    "lastPushOK": true,
    "piURL": "http://100.x.x.x:8090"
  }
}
```
