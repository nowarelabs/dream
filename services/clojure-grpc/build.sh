#!/usr/bin/env bash
set -euo pipefail

SERVICE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SERVICE_ROOT"

: "${CLJ_CACHE:=${TMPDIR:-/tmp}/dream-clojure-cache}"
export CLJ_CACHE
mkdir -p "$CLJ_CACHE"

mkdir -p gen classes
protoc --proto_path=proto --java_out=gen proto/echo.proto
javac -cp "$(clojure -Spath)" -d classes $(find gen -name '*.java')
