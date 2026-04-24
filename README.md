# operator

Toggleable control modes for Claude Code.

## Commands

| Command | What it does |
|---------|-------------|
| `/operator` | Show status of all controls |
| `/teach` | Toggle teaching mode on/off |
| `/scope` | Toggle scope watch on/off |

## Modes

**Teaching Mode** — Claude narrates every action in plain language before taking it. What it's doing, why, and what to expect. Useful for learning, auditing, or working with non-technical users.

**Scope Watch** — Tracks which directories Claude touches during a session. Warns you the moment it starts expanding outside the original context — before it's already happened.

## Setup

```bash
git clone https://github.com/humanstandardsystems/operator.git
cd your-project
bash /path/to/operator/install.sh
```

Both modes are off by default. Toggle them anytime with `/teach` or `/scope`.

## License

MIT
