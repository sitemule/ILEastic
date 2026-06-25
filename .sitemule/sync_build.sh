#!/usr/bin/env bash
# sync_build.sh — [optionally] rsync to IBM i then run gmake via SSH
#
# Usage: .sitemule/sync_build.sh [gmake-target] [extra-make-vars...]
#
# Config (in .env or as environment variables):
#   I_HOST       SSH hostname or alias for the IBM i
#   DELPOY_PATH  Deployment path on the IBM i  (e.g. /prj/ILEastic)
#   SKIP_RSYNC   Set to "true" to force-skip rsync (auto-detected for network mounts)
#
# Examples:
#   .sitemule/sync_build.sh all
#   .sitemule/sync_build.sh current SRC=ileastic SRCDIR=src
#   .sitemule/sync_build.sh sync-only

# Load .env if present (does not override already-exported vars)
if [ -f ".env" ]; then
    set -o allexport
    # shellcheck disable=SC1091
    source .env
    set +o allexport
fi

: "${I_HOST:?I_HOST is not set. Add it to .env or export it before running.}"
: "${DELPOY_PATH:?DELPOY_PATH is not set. Add it to .env or export it before running.}"

MAKE_TARGET="${1:-all}"
shift 1 || true          # remaining args are extra make variables (e.g. SRC=foo SRCDIR=src)
MAKE_EXTRA="$*"

# ---------------------------------------------------------------
# Auto-detect if the workspace is on a network/IFS share.
# When the project folder is mounted from the IBM i over SMB/NFS
# and opened directly (rather than cloned locally), rsync is not
# needed — edits already land on the IFS.
#
# df -P shows the device as //host/share for SMB/NFS mounts on
# macOS and Linux.  Users can also set SKIP_RSYNC=true in .env.
# ---------------------------------------------------------------
if [ -z "$SKIP_RSYNC" ]; then
    _fs=$(df -P . 2>/dev/null | awk 'NR==2{print $1}')
    case "$_fs" in
        //*) SKIP_RSYNC=true ;;
        *)   SKIP_RSYNC=false ;;
    esac
fi

# ---------------------------------------------------------------
# 0. Generate src/githash.c locally (IBM i has no git repo).
#    Skipped when working directly on the IFS share.
# ---------------------------------------------------------------
if [ "$SKIP_RSYNC" != "true" ]; then
    GITSHORT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    GITHASH=$(git rev-parse --verify HEAD 2>/dev/null || echo "unknown")
    echo "#pragma comment(copyright,\"System & Method A/S - Sitemule: git checkout ${GITSHORT} (hash: ${GITHASH})\")" \
        > src/githash.c
    echo ">>> Git hash: ${GITSHORT}"
fi

# ---------------------------------------------------------------
# 1. Sync source files (local clone → IBM i only)
#
# --inplace: write directly to the target file instead of using a
#   temp file + rename. Avoids "Device busy (16)" on IBM i IFS when
#   another job has the directory open.
# --ignore-errors: treat per-file errors as warnings so the build
#   still runs even if one locked file couldn't be updated.
# ---------------------------------------------------------------
if [ "$SKIP_RSYNC" = "true" ]; then
    echo ">>> Working from IFS share — skipping rsync."
else
    echo ">>> Syncing to $I_HOST:$DELPOY_PATH ..."
    rsync -az \
        --inplace \
        --ignore-errors \
        --exclude '.git/' \
        --exclude '.gitignore' \
        --exclude '.gitattributes' \
        --exclude '.vscode/' \
        --exclude '.DS_Store' \
        --exclude '*.o' \
        --exclude 'examples/errorlist.txt' \
        --rsync-path="/QOpenSys/pkgs/bin/rsync" \
        --omit-dir-times \
        --no-perms \
        "./" \
        "$I_HOST:$DELPOY_PATH" || echo ">>> rsync finished with warnings (continuing to build)"
fi

# ---------------------------------------------------------------
# 2. Build on IBM i (skip if target is sync-only)
# ---------------------------------------------------------------
if [ "$MAKE_TARGET" = "sync-only" ]; then
    echo ">>> Sync complete (no build requested)."
    exit 0
fi

echo ">>> Building: gmake $MAKE_TARGET $MAKE_EXTRA"

if [ "$MAKE_TARGET" = "all-here" ]; then
    # Walk up from SRCDIR on IBM i to find the nearest makefile, then run gmake all.
    SRCDIR_VAL=$(echo "$MAKE_EXTRA" | grep -oE 'SRCDIR=[^ ]+' | sed 's/SRCDIR=//')
    ssh "$I_HOST" "
        PATH=/QOpenSys/pkgs/bin:\$PATH
        dir='$DELPOY_PATH/$SRCDIR_VAL'
        while true; do
            if [ -f \"\$dir/makefile\" ] || [ -f \"\$dir/Makefile\" ]; then
                break
            fi
            if [ \"\$dir\" = '$DELPOY_PATH' ] || [ \"\$dir\" = '/' ]; then
                echo 'ERROR: No makefile found above $SRCDIR_VAL' >&2
                exit 1
            fi
            dir=\$(dirname \"\$dir\")
        done
        echo \">>> gmake all in: \$dir\"
        cd \"\$dir\" && gmake all
    "
elif [ "$MAKE_TARGET" = "current" ]; then
    # Walk up from SRCDIR on IBM i until a makefile is found, then invoke
    # that directory's own suffix rules with the bare basename as make target.
    SRCDIR_VAL=$(echo "$MAKE_EXTRA" | grep -oE 'SRCDIR=[^ ]+' | sed 's/SRCDIR=//')
    SRC_VAL=$(echo "$MAKE_EXTRA"    | grep -oE '\bSRC=[^ ]+'   | sed 's/SRC=//')
    SRC_TARGET="${SRC_VAL%.*}"   # strip extension — make target is always basename
    ssh "$I_HOST" "
        PATH=/QOpenSys/pkgs/bin:\$PATH
        dir='$DELPOY_PATH/$SRCDIR_VAL'
        while true; do
            if [ -f \"\$dir/makefile\" ] || [ -f \"\$dir/Makefile\" ]; then
                break
            fi
            if [ \"\$dir\" = '$DELPOY_PATH' ] || [ \"\$dir\" = '/' ]; then
                echo 'ERROR: No makefile found above $SRCDIR_VAL' >&2
                exit 1
            fi
            dir=\$(dirname \"\$dir\")
        done
        echo \">>> gmake $SRC_TARGET OUTPUT=*PRINT in: \$dir\"
        cd \"\$dir\" && gmake $SRC_TARGET OUTPUT=*PRINT
        if [ \"\$dir\" = '$DELPOY_PATH/src' ]; then
            cd '$DELPOY_PATH' && gmake bind-update
        fi
    "
else
    ssh "$I_HOST" \
        "PATH=/QOpenSys/pkgs/bin:\$PATH; cd '$DELPOY_PATH' && gmake $MAKE_TARGET $MAKE_EXTRA"
fi
