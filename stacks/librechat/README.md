# LibreChat stack

Self-hosted LibreChat **v0.8.8** with this repo's configuration layered on a pinned upstream release.

## Design
| Path | Contents |
|---|---|
| `~/apps/LibreChat` | Upstream clone, pinned tag, never modified |
| `stacks/librechat/` (this folder) | Override, `librechat.yaml`, setup script, all versioned here |
| Symlinks | Connect the two, so upstream upgrades never touch local config |

## Security decisions
- All published ports bound to `127.0.0.1` via `!override` (upstream binds to all interfaces)
- Databases (MongoDB, Meilisearch, pgvector) have no published ports and are reachable only on the internal Compose network
- Upstream `*-dev:latest` images replaced: app pinned by tag, RAG API and admin panel pinned by `sha256` digest
- All secrets generated with `openssl rand`, never the published `.env.example` defaults
- Open registration disabled after creating the admin account

## Usage
```bash
./setup.sh                                   # first install or repair
LIBRECHAT_TAG=v0.8.9 APP_DIR=~/apps/LibreChat-new ./setup.sh   # upgrade test
```
Services: LibreChat → http://localhost:3080 · Admin panel → http://localhost:3000
