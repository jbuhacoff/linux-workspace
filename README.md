# linux-workspace

This package installs an alias `w` that makes it easy to define and use
multiple workspaces. The workspaces are defined as `.env` files in the
`~/.workspace` directory. Type `w <name>` (without the `.env` extension)
to switch to that workspace, which means source the content of the `.env`
file to the current shell. 

## Managing workspaces

Here are some example workspace definitions:

**~/.workspace/project1.env**

    REMOTE_HOST=192.168.50.50
    cd ~/Documents/Projects/Project1

**~/.workspace/project2.env**

    REMOTE_HOST=192.168.20.80
    cd ~/Documents/Projects/Project2

To list available workspaces:

    w -l
    w --list

To switch between the workspaces, just type:

    w <workspace>
    w project1
    w project2

When you switch to a workspace, the environment variable `WORKSPACE` is
exported with the name of the workspace.

To print the environment variables exported from the current workspace:

    w -p
    w --print

To print the environment variables from any other workspace:

    w -p <workspace>
    w --print <workspace>

Switching to a new workspace doesn't clear any environment variables set
by a previous workspace. There is a shortcut for cleaning up the environment:

    w -r
    w --reset

## Workspace rsync shortcut

It can be helpful to have a quick command to run rsync from the current directory 
(under a pre-defined workspace) to a remote directory (that is also pre-defined).

The `wsync` command is a simple wrapper around `rsync` that does exactly that. It
relies on variables that are set in the environment:

    WORKSPACE_REMOTE_HOST (hostname or ipaddress)
    WORKSPACE_REMOTE_USER (to use with ssh login)
    WORKSPACE_REMOTE_PATH (remote equivalent of WORKSPACE_PATH)
    WORKSPACE_PATH (local directory to switch into when entering workspace)

Here is an example workspace definition:

**~/.workspace/project3.env**

    WORKSPACE_REMOTE_HOST=192.168.20.80
    WORKSPACE_REMOTE_USER=me
    WORKSPACE_REMOTE_PATH=workspace
    WORKSPACE_PATH=~/Documents/Projects/Project3
    cd $WORKSPACE_PATH

The following sequence of commands illustrates how the `wsync` wrapper works:

    w project3
    mkdir -p test
    touch test/myfile
    ssh $WORKSPACE_REMOTE_USER@$WORKSPACE_REMOTE_HOST "mkdir -p $WORKSPACE_REMOTE_PATH"
    cd test
    wsync
    ssh $WORKSPACE_REMOTE_USER@$WORKSPACE_REMOTE_HOST "ls $WORKSPACE_REMOTE_PATH/test"

Expected output:

    myfile

