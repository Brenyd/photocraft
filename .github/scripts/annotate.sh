#!/usr/bin/env bash
# Run a command; when it fails, publish the end of its output (errors first) as error
# annotations, which the checks API exposes without log access. Used by hdr-check.yml.
set -uo pipefail
log=$(mktemp)
"$@" 2>&1 | tee "$log"
status=${PIPESTATUS[0]}
if [ "$status" -ne 0 ]; then
  python3 - "$log" "$*" <<'PY'
import sys
text = open(sys.argv[1], errors="replace").read().splitlines()
# Compiler errors and test failures first, then the tail of the log.
keep = []
for i, line in enumerate(text):
    if line.startswith(("error", "warning: unused")) or "panicked at" in line or line.startswith("---- "):
        keep.extend(text[i:i + 14])
keep.extend(["--- tail ---"] + text[-60:])
blob = "\n".join(keep)
chunks = [blob[i:i + 3800] for i in range(0, len(blob), 3800)][:9]
for n, c in enumerate(chunks):
    c = c.replace("%", "%25").replace("\r", "").replace("\n", "%0A")
    print(f"::error title={sys.argv[2][:80]} ({n + 1}/{len(chunks)})::{c}")
PY
fi
exit "$status"
