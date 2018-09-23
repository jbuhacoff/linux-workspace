#!/bin/bash

workspace_sync() {
    if [ -z "$WORKSPACE_PATH" ];           then echo "required: WORKSPACE_PATH" >&2;           return 1; fi
    if [ -z "$WORKSPACE_REMOTE_HOST" ];    then echo "required: WORKSPACE_REMOTE_HOST" >&2;    return 1; fi
    if [ -z "$WORKSPACE_REMOTE_USER" ];    then echo "required: WORKSPACE_REMOTE_USER" >&2;    return 1; fi
    if [ -z "$WORKSPACE_REMOTE_PATH" ];    then echo "required: WORKSPACE_REMOTE_PATH" >&2;    return 1; fi

    # locate current directory relative to local workspace path
    if ! [[ "$PWD" =~ ^$WORKSPACE_PATH ]]; then
        echo "not in workspace: $PWD" >&2
        return 1
    fi
    local rel_path=$(realpath --relative-to=$WORKSPACE_PATH $PWD)
    
    # ensure same relative path exists on remote server before we sync
    ssh $WORKSPACE_REMOTE_USER@$WORKSPACE_REMOTE_HOST "mkdir -p $WORKSPACE_REMOTE_PATH/$rel_path"

    # sync the files to remote server.
    # example of WORKSPACE_REMOTE_SYNC_OPTS="--delete --exclude target --exclude .build"
    rsync -e "ssh -l $WORKSPACE_REMOTE_USER" ${WORKSPACE_RSYNC_OPTS:-"-crptvzL"} $PWD/ $WORKSPACE_REMOTE_HOST:$WORKSPACE_REMOTE_PATH/$rel_path/
}

workspace_sync || exit 1
