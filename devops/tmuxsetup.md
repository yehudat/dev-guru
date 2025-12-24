# DV Suggested Layout

## Session: "tm-bfm" (one session per block/project)

```text
├── Window 1: "edit" ─────────────────────────
│   └── Full pane: vim (RTL + TB files)
│
├── Window 2: "sim" ──────────────────────────
│   ┌─────────────────┬─────────────────┐
│   │ Run sim         │ Watch logs      │
│   │ make / verilator│ tail -f sim.log │
│   │                 │ (use h alias)   │
│   └─────────────────┴─────────────────┘
│
├── Window 3: "debug" ────────────────────────
│   ┌─────────────────┬─────────────────┐
│   │ Waveform/DVE    │ grep logs       │
│   │ verdi / gtkwave │ analysis        │
│   └─────────────────┴─────────────────┘
│
└── Window 4: "git" ──────────────────────────
    └── Full pane: git ops, PR reviews
```

## Workflow

| Task          | Where                          |
|---------------|--------------------------------|
| Write RTL/TB  | Alt+1 → vim                    |
| Run sim       | Alt+2 → left pane              |
| Watch output  | Alt+2 → right pane: h make sim |
| Debug failure | Alt+3 → grep logs, open waves  |
| Commit        | Alt+4 → git                    |

## Quick Setup Commands

### Create session
  `tmux new -s tm-bfm`

### Create windows
  `C-a c`         # sim window
  `C-a c`         # debug window
  `C-a c`         # git window

### Rename windows

  `C-a ,`         # then type name

### Split sim window

  `C-a |`         # vertical split for log watching

## Pro Tips

1. Your h alias shines in sim window: h make run colorizes UVM output
2. Zoom (C-a z) when you need full screen for vim or log reading
3. Copy mode (C-a [) to scroll back through sim output, / to search errors
4. Session per block: tmux new -s axi-bridge for another block, C-a s to switch

