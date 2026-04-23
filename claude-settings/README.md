# Claude Code Settings

Example `settings.local.json` for a Go-focused development workflow with statusline support.

## Permissions

### Web Access

| Permission | Why |
|---|---|
| `WebSearch` | General research during development |
| `WebFetch(domain:proxy.golang.org)` | Go module proxy for dependency resolution |
| `WebFetch(domain:sum.golang.org)` | Go checksum database for module verification |
| `WebFetch(domain:golang.org)` | Go documentation and standard library reference |
| `WebFetch(domain:gopkg.in)` | Legacy Go package imports that redirect via gopkg.in |
| `WebFetch(domain:go.googlesource.com)` | Go source repositories (stdlib, tools, etc.) |
| `WebFetch(domain:github.com)` | GitHub repos, issues, and documentation |
| `WebFetch(domain:api.github.com)` | GitHub API for PR/issue operations |
| `WebFetch(domain:raw.githubusercontent.com)` | Raw file content from GitHub repos |

### Go Toolchain

| Permission | Why |
|---|---|
| `Bash(go build:*)` | Compile packages and dependencies |
| `Bash(go test:*)` | Run tests |
| `Bash(go run:*)` | Compile and run Go programs |
| `Bash(go fmt:*)` | Format Go source code |
| `Bash(go vet:*)` | Static analysis for common mistakes |
| `Bash(go get:*)` | Add/update module dependencies |
| `Bash(go mod:*)` | Module maintenance (tidy, vendor, download, etc.) |
| `Bash(go env:*)` | Inspect Go environment variables |
| `Bash(go install:*)` | Install Go binaries |

### Git Operations

| Permission | Why |
|---|---|
| `Bash(git add:*)` | Stage changes |
| `Bash(git commit:*)` | Create commits |
| `Bash(git status:*)` | Check working tree status |
| `Bash(git log:*)` | View commit history |
| `Bash(git diff:*)` | View changes |
| `Bash(git push:*)` | Push to remote |
| `Bash(git stash:*)` | Stash/unstash work in progress |
| `Bash(git branch:*)` | Branch management |
| `Bash(git checkout:*)` | Switch branches or restore files |
| `Bash(git merge:*)` | Merge branches |
| `Bash(git remote:*)` | Manage remote repositories |
| `Bash(git fetch:*)` | Fetch from remotes |
| `Bash(git rebase:*)` | Rebase branches |
| `Bash(git tag:*)` | Tag management |

### Infrastructure & DevOps

| Permission | Why |
|---|---|
| `Bash(./scripts/*.sh:*)` | Project-local shell scripts |
| `Bash(docker:*)` | Container management |
| `Bash(docker compose:*)` | Multi-container orchestration |
| `Bash(psql:*)` | PostgreSQL client for database operations |
| `Bash(goose:*)` | Database migration tool |
| `Bash(curl:*)` | HTTP requests for API testing |
| `Bash(gh:*)` | GitHub CLI for PR/issue workflows |

### Statusline & Shell Utilities

These commands are needed by the Claude Code statusline script and general shell operations.

| Permission | Why |
|---|---|
| `Bash(jq:*)` | JSON parsing -- used by statusline to read API responses and config |
| `Bash(bc:*)` | Arithmetic -- used by statusline for cost/token calculations |
| `Bash(basename:*)` | Path manipulation -- used by statusline to display current project name |
| `Bash(printf:*)` | Formatted output -- used by statusline for aligned text rendering |
| `Bash(echo:*)` | Basic output |
| `Bash(bash:*)` | Shell script execution |
| `Bash(sh:*)` | POSIX shell execution |
| `Bash(cat:*)` | File reading |
| `Bash(grep:*)` | Pattern matching |
| `Bash(sed:*)` | Stream editing |
| `Bash(awk:*)` | Text processing |

## Sandbox Configuration

### General

| Setting | Value | Why |
|---|---|---|
| `enabled` | `true` | Restricts filesystem and network access to prevent unintended side effects |
| `autoAllowBashIfSandboxed` | `true` | Auto-approves Bash commands when sandboxed, since the sandbox itself enforces boundaries |

### Network

| Setting | Value | Why |
|---|---|---|
| `allowAllUnixSockets` | `true` | Allows communication over Unix sockets (needed for 1Password SSH agent, local database sockets, etc.) |

### Filesystem -- Read Access

Default policy: deny reads to `~/` (home directory) to prevent access to dotfiles, credentials, and unrelated projects.

| Path | Why |
|---|---|
| `.` | Current working directory -- the project being worked on |
| `~/.1password/agent.sock` | 1Password SSH agent socket for git signing/auth |
| `~/.gitconfig` | Git configuration (needed for commits, aliases, etc.) |
| `/opt/1Password` | 1Password CLI/browser integration binaries |
| `$TMPDIR` | Temporary files -- used by statusline and build tools for intermediate output |

### Filesystem -- Write Access

| Path | Why |
|---|---|
| `~/.1password/agent.sock` | 1Password SSH agent socket communication |
| `/run/user/1000/agent-browser` | Agent-browser runtime socket |
| `$TMPDIR` | Temporary files -- statusline and build tools write intermediate results here |
| `/dev/stdout` | Standard output -- needed by statusline script to render output |
| `/dev/stderr` | Standard error -- needed by statusline script to render error/status messages |
