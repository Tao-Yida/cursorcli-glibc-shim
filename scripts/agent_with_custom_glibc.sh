#!/bin/bash

# Run the internal node of the agent with custom glibc 2.28 without modifying the agent script itself
# Reference implementation: ~/.local/bin/agent
#   NODE_BIN="$SCRIPT_DIR/node"
#   exec -a "$0" "$NODE_BIN" --use-system-ca "$SCRIPT_DIR/index.js" "$@"

set -euo pipefail

echo "Starting agent (node) with custom glibc 2.28..."

# Find the directory where the agent script is located
AGENT_PATH="$HOME/.local/bin/agent"
if command -v realpath >/dev/null 2>&1; then
  SCRIPT_DIR="$(dirname "$(realpath "$AGENT_PATH")")"
else
  SCRIPT_DIR="$(dirname "$AGENT_PATH")"
fi

NODE_BIN="$SCRIPT_DIR/node"
INDEX_JS="$SCRIPT_DIR/index.js"

if [ ! -x "$NODE_BIN" ]; then
  echo "Error: Executable node not found: $NODE_BIN" >&2
  exit 1
fi

if [ ! -f "$INDEX_JS" ]; then
  echo "Error: index.js not found: $INDEX_JS" >&2
  exit 1
fi

# Save original environment variables
ORIGINAL_LD_LIBRARY_PATH="${LD_LIBRARY_PATH-}"
ORIGINAL_LANG="${LANG-}"
ORIGINAL_LC_ALL="${LC_ALL-}"
ORIGINAL_LOCPATH="${LOCPATH-}"
ORIGINAL_TERM="${TERM-}"

# Set up environment with minimal impact on other programs:
# 1. Don't add glibc-2.28 to LD_LIBRARY_PATH to avoid system programs mistakenly using it
# 2. Only add gcc lib path to LD_LIBRARY_PATH to resolve libgcc_s.so.1 / pthread_cancel issues
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

if [ -d "$HOME/opt/glibc-2.28/lib/locale" ]; then
    export LOCPATH="$HOME/opt/glibc-2.28/lib/locale"
fi

export LD_LIBRARY_PATH="$HOME/opt/gcc-9.5.0/lib64:${LD_LIBRARY_PATH-}"

# Start node with custom glibc dynamic linker
GLIBC_LINKER="$HOME/opt/glibc-2.28/lib/ld-linux-x86-64.so.2"
GLIBC_LIB_PATH="$HOME/opt/glibc-2.28/lib:$HOME/opt/gcc-9.5.0/lib64:/lib64:/usr/lib64"

if [ ! -x "$GLIBC_LINKER" ]; then
  echo "Error: Custom glibc linker not found: $GLIBC_LINKER" >&2
  # Restore environment before exiting
  export LD_LIBRARY_PATH="$ORIGINAL_LD_LIBRARY_PATH"
  [ -n "$ORIGINAL_LANG" ] && export LANG="$ORIGINAL_LANG"
  if [ -n "$ORIGINAL_LC_ALL" ]; then
      export LC_ALL="$ORIGINAL_LC_ALL"
  else
      unset LC_ALL || true
  fi
  if [ -n "$ORIGINAL_LOCPATH" ]; then
      export LOCPATH="$ORIGINAL_LOCPATH"
  else
      unset LOCPATH || true
  fi
  [ -n "$ORIGINAL_TERM" ] && export TERM="$ORIGINAL_TERM"
  exit 1
fi

# Execute: Mimic the agent script, just wrap it with custom glibc
"$GLIBC_LINKER" \
  --library-path "$GLIBC_LIB_PATH" \
  "$NODE_BIN" --use-system-ca "$INDEX_JS" "$@"
RETURN_CODE=$?

# Restore environment variables (ensure no impact on external shell)
export LD_LIBRARY_PATH="$ORIGINAL_LD_LIBRARY_PATH"
[ -n "$ORIGINAL_LANG" ] && export LANG="$ORIGINAL_LANG"
if [ -n "$ORIGINAL_LC_ALL" ]; then
    export LC_ALL="$ORIGINAL_LC_ALL"
else
    unset LC_ALL || true
fi
if [ -n "$ORIGINAL_LOCPATH" ]; then
    export LOCPATH="$ORIGINAL_LOCPATH"
else
    unset LOCPATH || true
fi
[ -n "$ORIGINAL_TERM" ] && export TERM="$ORIGINAL_TERM"

exit $RETURN_CODE
