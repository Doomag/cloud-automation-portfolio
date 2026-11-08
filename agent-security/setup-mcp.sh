#!/usr/bin/env bash
# Register MCP servers for Claude Code (user scope). No secrets stored:
# n8n uses OAuth (run /mcp -> Authenticate), AWS uses the SSO profile below.
set -euo pipefail

claude mcp add --transport http --scope user n8n http://localhost:5678/mcp-server/http

claude mcp add aws --scope user \
  -e AWS_PROFILE=agent-ro \
  -e AWS_REGION=eu-central-1 \
  -- uvx mcp-proxy-for-aws@latest https://aws-mcp.us-east-1.api.aws/mcp \
     --metadata AWS_REGION=eu-central-1

claude mcp list
