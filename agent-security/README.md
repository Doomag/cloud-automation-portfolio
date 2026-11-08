# Agent security: least-privilege Claude Code

An AI coding agent that can **inspect** AWS and n8n, but cannot **change** AWS,
**read** credentials, or **disable** its own guardrails.

## Layers
| Layer | Mechanism | Enforced by |
|---|---|---|
| AWS permissions | IAM Identity Center permission set `ViewOnlyAccess` (metadata only, no data reads) | AWS IAM |
| Default profile | `AWS_PROFILE=agent-ro`; admin requires explicit `--profile lab` | Shell config |
| Credential isolation | Sandbox `denyRead`: `~/.aws`, `~/.ssh`, `~/.config/gh`, `.env` files | Linux namespaces (bubblewrap) |
| No escape hatch | `allowUnsandboxedCommands: false`, `failIfUnavailable: true` | Claude Code |
| Capability-based access | AWS reachable only via MCP server pinned to `agent-ro`; n8n via OAuth, per-workflow opt-in | MCP config |

## Verification (negative tests)
| Test | Expected | Result |
|---|---|---|
| `aws s3 mb` with `agent-ro` | AccessDenied (implicit deny) | ✅ |
| Canary file in a `denyRead` path, read via sandboxed Bash | Hidden (`No such file or directory`) | ✅ |
| Agent edits its own `~/.claude/settings.json` | Refused (write-protected) | ✅ |
| `sts:GetCallerIdentity` via AWS MCP | `ViewOnlyAccess` role | ✅ |

## Files
- `claude-settings.json`: user-level Claude Code settings (permissions + sandbox)
- `setup-mcp.sh`: MCP server registration, no secrets stored
