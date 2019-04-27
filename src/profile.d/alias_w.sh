#!/bin/bash

declare -a WORKSPACE_LIST=()

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

    local err=0
        
    # option to print content of current workspace or specified workspace
    if [ "$1" == "-p" ] || [ "$1" == "--print" ]; then
        shift
        declare -a PRINT_LIST=()
        if [ $# -gt 0 ]; then
            PRINT_LIST=( "$@" )
        else
            PRINT_LIST=( "${WORKSPACE_LIST[@]}" )
        fi
        if [ ${#PRINT_LIST[@]} -eq 0 ]; then
            echo "no workspace selected" >&2
            return 1
        fi
        for item in "${PRINT_LIST[@]}"
        do
            if [ -f "$HOME/.workspace/$item.env" ]; then
                echo "# workspace: $item"
                cat $HOME/.workspace/$item.env
                echo
            else
                echo "workspace not found: $item" >&2
                ((err++))
            fi
        done
        return $err
    fi

    # option to reset the current shell environment (instead of restarting terminal)
    if [ "$1" == "-r" ] || [ "$1" == "--reset" ]; then
        reset
        exec env -i USER=$USER HOME=$HOME TERM=$TERM /bin/bash -l
    fi

    # main function of 'w' alias is to switch to the specified workspace
    until [ $# -eq 0 ]
    do
        if [ -f "$HOME/.workspace/$1.env" ]; then
            source $HOME/.workspace/$1.env
            
            # remove the workspace name from the list, if present
            declare -a EDIT_WORKSPACE_LIST=()
            for item in "${WORKSPACE_LIST[@]}"
            do
                if [[ "$item" != "$1" ]]; then
                    EDIT_WORKSPACE_LIST+=("$item")
                fi
            done
            WORKSPACE_LIST=("${EDIT_WORKSPACE_LIST[@]}")
            
            # append the workspace name to the list
            WORKSPACE_LIST+=("$1")
            
            export WORKSPACE="${WORKSPACE_LIST[@]}"
        else
            echo "workspace not found: $1" >&2
            ((err++))
        fi
        shift
    done

    return $err
}

alias w='w_exec'
