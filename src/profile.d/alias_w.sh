#!/bin/bash

w_exec() {
    if [ -z "$1" ]; then
        if [ -n "$WORKSPACE" ]; then
            echo "$WORKSPACE"
            return 0
        else
            return 1
        fi
    fi

    # option to list available workspaces
    if [ "$1" == "-l" ] || [ "$1" == "--list" ]; then
        if [ ! -d $HOME/.workspace ]; then mkdir -p $HOME/.workspace; fi
        find $HOME/.workspace -mindepth 1 -maxdepth 1 -type f -name "*.env" | xargs --no-run-if-empty -n 1 -I{} basename {} .env
        return $?
    fi

    # option to print content of current workspace or specified workspace
    if [ "$1" == "-p" ] || [ "$1" == "--print" ]; then
        local toprint=${2:-$WORKSPACE}
        if [ -n "$toprint" ]; then
            if [ -f "$HOME/.workspace/$toprint.env" ]; then
                cat $HOME/.workspace/$toprint.env
                return 0
            else
                echo "workspace not found: $toprint" >&2
                return 1
            fi
        else
            echo "no workspace selected" >&2
            return 1
        fi
        return $?
    fi

    # option to reset the current shell environment (instead of restarting terminal)
    if [ "$1" == "-r" ] || [ "$1" == "--reset" ]; then
        reset
        exec env -i USER=$USER HOME=$HOME TERM=$TERM /bin/bash -l
        return
    fi

    # main function of 'w' alias is to switch to the specified workspace
    if [ -f "$HOME/.workspace/$1.env" ]; then
        source $HOME/.workspace/$1.env
        export WORKSPACE=$1
        return 0
    fi

    echo "workspace not found: $1" >&2
    return 1
}

alias w='w_exec'
