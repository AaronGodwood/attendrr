#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

flutter test --coverage
python3 scripts/augment_lcov_functions.py --in coverage/lcov.info --out coverage/lcov.info --root .
genhtml --ignore-errors category coverage/lcov.info -o coverage/html

echo "Coverage report generated at coverage/html/index.html"
