#!/bin/bash

workspace_tunnel() {
    if [ -z "$WORKSPACE_REMOTE_HOST" ];    then echo "required: WORKSPACE_REMOTE_HOST" >&2;    return 1; fi
    
    local ssh_user_opts   
    if [ -n "$WORKSPACE_REMOTE_USER" ]; then
        ssh_user_opts="-l $WORKSPACE_REMOTE_USER"
    fi
    
    echo "Ctrl+C to disconnect tunnel"
    ssh $WORKSPACE_SSH_OPTS $WORKSPACE_SSH_TUNNEL_OPTS $ssh_user_opts -N $WORKSPACE_REMOTE_HOST
}

workspace_tunnel "$@" || exit 1
