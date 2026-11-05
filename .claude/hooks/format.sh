#!/bin/bash

# PostToolUse hook for Claude Code (Write|Edit)
# Formats the file that was just written using the project's pinned formatters:
#   - client/**  (.vue .js .ts .css .html .json) -> Prettier from client/node_modules
#   - server/**, tests/**  (.py)                 -> Ruff from server/.venv
# Install them with `npm install` in client/ and `uv sync` in server/.
# Never blocks the edit: missing formatters or format errors are reported, not fatal.

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"

FILE=$(jq -r '.tool_response.filePath // .tool_input.file_path // empty')
[ -z "$FILE" ] || [ ! -f "$FILE" ] && exit 0

# Only touch files inside this repository
case "$FILE" in
  "$ROOT"/*) REL="${FILE#"$ROOT"/}" ;;
  *) exit 0 ;;
esac

case "$REL" in
  client/node_modules/*|client/dist/*) exit 0 ;;

  client/*.vue|client/*.js|client/*.ts|client/*.css|client/*.html|client/*.json)
    PRETTIER="$ROOT/client/node_modules/.bin/prettier"
    if [ ! -x "$PRETTIER" ]; then
      echo '{"systemMessage": "format hook: prettier not installed (run npm install in client/)"}'
      exit 0
    fi
    # Run from client/ so client/.prettierrc.json is picked up
    (cd "$ROOT/client" && "$PRETTIER" --write --log-level warn "$FILE") >&2 || \
      echo '{"systemMessage": "format hook: prettier failed, file left as written"}'
    ;;

  server/*.py|tests/*.py)
    RUFF="$ROOT/server/.venv/bin/ruff"
    if [ ! -x "$RUFF" ]; then
      echo '{"systemMessage": "format hook: ruff not installed (run uv sync in server/)"}'
      exit 0
    fi
    # tests/ has no ruff config of its own, so always use the server's settings
    "$RUFF" format --quiet --config "$ROOT/server/pyproject.toml" "$FILE" >&2 || \
      echo '{"systemMessage": "format hook: ruff failed, file left as written"}'
    ;;
esac

exit 0
