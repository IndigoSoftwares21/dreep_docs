#!/usr/bin/env bash
#
# Runs `mint dev` with the API playground pointed at a local dreep_server.
#
# openapi.yaml ships with only the production server, so readers of the deployed
# docs never see a localhost option. This script temporarily prepends the local
# server — making it the playground's default — and restores the original file
# when the dev server exits.
#
# Usage: ./dev.sh [mint dev args...]
#        DREEP_LOCAL_API_URL=http://localhost:8080 ./dev.sh

set -euo pipefail
cd "$(dirname "$0")"

SPEC="openapi.yaml"
BACKUP=".openapi.yaml.orig"
LOCAL_URL="${DREEP_LOCAL_API_URL:-http://localhost:6969}"

cp "$SPEC" "$BACKUP"
trap 'mv -f "$BACKUP" "$SPEC"' EXIT

node -e '
const fs = require("fs");
const [spec, url] = process.argv.slice(1);
const lines = fs.readFileSync(spec, "utf8").split("\n");
const i = lines.indexOf("servers:");
if (i === -1) throw new Error(`no top-level "servers:" block in ${spec}`);
lines.splice(i + 1, 0, `  - url: ${url}`, "    description: Local development");
fs.writeFileSync(spec, lines.join("\n"));
' "$SPEC" "$LOCAL_URL"

echo "Playground default server: $LOCAL_URL (restored to production on exit)"

# Falls back to npx so a fresh checkout doesn't need `npm i -g mint` first.
if command -v mint >/dev/null 2>&1; then
    mint dev "$@"
else
    npx --yes mint dev "$@"
fi
