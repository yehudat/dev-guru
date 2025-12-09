# VSCode Extensions and How to Configure Them

## MARP

1. Open `settings.json`. And add the following lines.
```json
    "markdown.marp.html": "default",
    "markdown.marp.browserPath": "/usr/bin/chrome-gnome-shell",
    "markdown.marp.themes": [
        "./theme/elbit_dv.css"
    ],
```
2. Make sure this code is wrapped with `{}` somewhere above in the code to match `json` syntax.
3. Optional: Set shortcuts for Markdown/MARP preview.
```json
    { "key": "ctrl+shift+m ctrl+shift+v", "command": "markdown.showPreviewToSide", "when": "editorTextFocus && vim.active" },
```