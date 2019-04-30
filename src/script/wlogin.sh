#!/bin/bash

workspace_login() {
    if [ -z "$WORKSPACE_REMOTE_HOST" ];    then echo "required: WORKSPACE_REMOTE_HOST" >&2;    return 1; fi
    
    local ssh_user_opts   
    if [ -n "$WORKSPACE_REMOTE_USER" ]; then
        ssh_user_opts="-l $WORKSPACE_REMOTE_USER"
    fi
    
    local cd_opts tty_opts
    if [ -n "$WORKSPACE_REMOTE_PATH" ]; then
        if [ $# -eq 0 ]; then
            tty_opts="-t"
            cd_opts="cd $WORKSPACE_REMOTE_PATH; \$SHELL"
        else
            cd_opts="cd $WORKSPACE_REMOTE_PATH; "
        fi
    fi
    
    ssh $WORKSPACE_SSH_OPTS $ssh_user_opts $tty_opts $WORKSPACE_REMOTE_HOST "$cd_opts $@"
}

workspace_login "$@" || exit 1
