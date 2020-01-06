#!/bin/bash

# usage 1: explicit remote path (will be automatically created)
# wsync /remote/path
# usage 2: remote path relative to remote workspace
# wsync

workspace_sync_path() {
    local remotedir="$1"

    if [ -z "$WORKSPACE_REMOTE_HOST" ];    then echo "required: WORKSPACE_REMOTE_HOST" >&2;    return 1; fi
    
    local ssh_user_expr;    
    if [ -n "$WORKSPACE_REMOTE_USER" ]; then
        ssh_user_expr="-l $WORKSPACE_REMOTE_USER"
    fi
    
    # ensure same relative path exists on remote server before we sync
    ssh $WORKSPACE_SSH_OPTS $ssh_user_expr $WORKSPACE_REMOTE_HOST "mkdir -p $remotedir"

    # sync the files to remote server.
    # example of WORKSPACE_REMOTE_SYNC_OPTS="--delete --exclude target --exclude .build"
    rsync -e "ssh $WORKSPACE_SSH_OPTS $ssh_user_expr" ${WORKSPACE_RSYNC_OPTS:-"-crptvzL"} $PWD/ $WORKSPACE_REMOTE_HOST:$remotedir/
}

workspace_sync_relative() {
    if [ -z "$WORKSPACE_PATH" ];           then echo "required: WORKSPACE_PATH" >&2;           return 1; fi
    if [ -z "$WORKSPACE_REMOTE_PATH" ];    then echo "required: WORKSPACE_REMOTE_PATH" >&2;    return 1; fi
    
    # locate current directory relative to local workspace path
    if ! [[ "$PWD" =~ ^$WORKSPACE_PATH ]]; then
        echo "not in workspace: $PWD" >&2
        return 1
    fi
    local rel_path=$(realpath --relative-to=$WORKSPACE_PATH $PWD)
    
    workspace_sync_path "$WORKSPACE_REMOTE_PATH/$rel_path"
}

if [ -n "$1" ]; then
    workspace_sync_path "$1" || exit 1
else
    workspace_sync_relative || exit 1
fi


