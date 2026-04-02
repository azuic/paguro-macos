# Claude Bridge Setup

Paguro ingests Claude usage through Claude Code's local status line integration.

The bridge script writes Claude's latest status-line JSON snapshot to:

`~/Library/Application Support/Paguro/bridges/claude-statusline-latest.json`

The app watches that file and computes per-session token deltas locally.

## Install

1. Make the bridge script executable:

```bash
chmod +x /Users/zuichen/Claude/paguro/scripts/claude-statusline-bridge.sh
```

2. Add this to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "/Users/zuichen/Claude/paguro/scripts/claude-statusline-bridge.sh",
    "padding": 1
  }
}
```

3. Interact with Claude Code once so the status line runs.

4. Open Paguro and select the Claude pet.

## Notes

- Paguro computes energy from `context_window.total_input_tokens` and `context_window.total_output_tokens`.
- Deltas are tracked per `session_id`, so multiple Claude sessions can feed the same Claude pet without double-counting.
- The current OpenAI pet is still on demo input until the OpenAI proxy path is implemented.
