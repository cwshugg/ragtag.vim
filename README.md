# ragtag.vim

A Vim plugin providing an interactive interface to the [ragtag](https://github.com/cwshugg/ragtag) CLI tool for managing `@tag(...)` annotations — and especially `@task(...)` tags — directly from inside Vim.

The plugin shells out to the `ragtag` binary for every operation; it does **not** reimplement any parsing logic.

## Features

* **Interactive task list buffer** with inline attribute editing (status, priority, owner, title, description)
* **Cursor-aware tag detection** — operate on the `@task(...)` tag under your cursor without typing its ID
* **One-keystroke status changes** — complete, activate, deactivate, block, abandon, or prioritize a task with a single command
* **In-buffer task creation** — generate a new `@task(...)` tag with proper indentation and insert it after the cursor line
* **Tag querying** — find tags in the current buffer and navigate them with `n`/`N`
* **Tag summaries** — display ragtag's summary output for any file or directory
* **Tab completion** for every command and flag via [argonaut.vim](https://github.com/cwshugg/argonaut.vim)
* **Short command aliases** for every command (e.g., `:Rtl` for `:RagtagTaskList`)
* **Custom highlight groups** for tags, status keywords, priority values, and the task list buffer — all defined via `highlight default` so they can be overridden in your colorscheme

## Requirements

1. The [ragtag](https://github.com/cwshugg/ragtag) CLI binary, available on your `PATH` (or configured via `g:ragtag_binary`)
2. [argonaut.vim](https://github.com/cwshugg/argonaut.vim) for argument parsing and tab completion

## Installation

Use your preferred plugin manager. With [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'cwshugg/argonaut.vim'
Plug 'cwshugg/ragtag.vim'
```

## Commands

All commands accept `-h` or `--help` to show their help menu.

| Command | Alias | Description |
| --- | --- | --- |
| `:RagtagTaskList` | `:Rtl` | Open the interactive task list buffer |
| `:RagtagTaskCreate` | `:Rtcr` | Create a new `@task(...)` and insert it after the cursor line |
| `:RagtagTaskGetAttr` | `:Rtga` | Print one attribute of the task under cursor (or by `--id`) |
| `:RagtagTaskSetAttr` | `:Rtsa` | Set one attribute of the task under cursor (or by `--id`) |
| `:RagtagTaskComplete` | `:Rtco` | Mark a task as done |
| `:RagtagTaskActivate` | `:Rta` | Set a task's status to active |
| `:RagtagTaskDeactivate` | `:Rtd` | Set a task's status to inactive |
| `:RagtagTaskBlock` | `:Rtb` | Set a task's status to blocked |
| `:RagtagTaskAbandon` | `:Rtab` | Set a task's status to abandoned |
| `:RagtagTaskPrioritize` | `:Rtp` | Set a task's priority (`--priority`/`-P`) |
| `:RagtagSummary` | `:Rs` | Show a tag summary for the current file or directory |
| `:RagtagQuery` | `:Rq` | Find tags in the current buffer and highlight them for `n`/`N` navigation |

The status-change and prioritize commands resolve the target task by either:

* `--id <ID>` / `-i <ID>` — an explicit task ID (or unambiguous prefix), or
* The `@task(...)` tag under the cursor when `--id` is omitted.

Tip: type `:Rt<Tab>` or `:R<Tab>` to discover commands via Vim's command-line completion.

## Configuration

| Variable | Default | Description |
| --- | --- | --- |
| `g:ragtag_binary` | `'ragtag'` | Path to the ragtag CLI binary |
| `g:ragtag_config` | `''` | Optional path to a ragtag config file (passed via `--config`) |
| `g:ragtag_default_path` | `''` | Default `--path` value (empty = current buffer's file) |
| `g:ragtag_print_prefix` | `'[ragtag.vim] '` | Prefix used for plugin messages |

## Documentation

* `:help ragtag` — full Vim help, including key mappings, configuration, and highlight groups
* [`docs/architecture.md`](docs/architecture.md) — module-level architecture and command specifications

## License

MIT
