# linux-workspace

This package installs an alias `w` that makes it easy to define and use
multiple workspaces. The workspaces are defined as `.env` files in the
`~/.workspace` directory.

Type `w <name>` (without the `.env` extension)
to switch to that workspace, which means source the content of the `.env`
file to the current shell. 

Type `w <project1> <project2> ...` to load multiple workspaces,
in order. Definitions in workspaces mentioned later in the list will override
definitions of the same name in workspaces mentioned earlier in the list.

## How to install

```
install -d /etc/profile.d
install -m 644 src/profile.d/*.sh /etc/profile.d/
install -d /usr/bin
install -m 755 src/script/wlogin.sh /usr/bin/wlogin
install -m 755 src/script/wsync.sh /usr/bin/wsync
install -m 755 src/script/wtunnel.sh /usr/bin/wtunnel
install -d $HOME/.workspace
```

## Managing workspaces

Here are some example workspace definitions:

**~/.workspace/project1.env**

    WORKSPACE_PATH=~/Documents/Projects/Project1
    cd $WORKSPACE_PATH

**~/.workspace/project2.env**

    WORKSPACE_PATH=~/Documents/Projects/Project2
    cd $WORKSPACE_PATH

To list available workspaces:

    w --list
    w -l

To switch between the workspaces, just type:

    w <workspace>
    w project1
    w project2

To load variables from multiple workspaces:

    w <workspace1> <workspace2> ...
    w project1 env1
    w project1 env2

If any workspaces in the list are not found, the command exits with a non-zero
code.

When you switch to a workspace, the environment variable `WORKSPACE` is
exported with the name of the workspace. If multiple workspaces are loaded,
the content of `WORKSPACE` indicates all loaded workspaces, in order.

If you later load additional workspaces, they will be appended to the list.
If you reload a workspace that appears before the end of the list, it will
be moved to the end of the list to reflect the fact that its definitions now
override any earlier definitions of the same name.

To print the environment variables exported from the current workspace:

    w --print
    w -p

To print the environment variables from any other workspace:

    w --print <workspace>
    w -p <workspace>
    w -p <workspace1> <workspace2> ...

If any workspaces in the list are not found, the command exits with a non-zero
code.
    
Switching to a new workspace doesn't clear any environment variables set
by a previous workspace. There is a shortcut for cleaning up the environment:

    w --reset
    w -r

## Workspace login shortcut

It can be helpful to have a quick command to login to a remote server that is
associated with a specific project, or workspace. If you define a few variables
in the workspace you can then use a single command to login to a remote server,
and use the same command to login to a different remote server when you are
working on a different project. 

The `wlogin` command is a simple wrapper around `ssh` that uses variables that
are set in the environment:

    WORKSPACE_REMOTE_HOST (hostname or ipaddress; required without default)
    WORKSPACE_REMOTE_USER (to use with ssh login; default is local username)
    WORKSPACE_SSH_OPTS (customized options for ssh, should NOT include "-l username"; default is none)

Here is an example of a workspace definition that specifies how to login to
a remote server:

**~/.workspace/server1.env**

    WORKSPACE_REMOTE_HOST=192.168.20.80
    WORKSPACE_REMOTE_USER=me
    WORKSPACE_SSH_OPTS="-i ~/.ssh/id_rsa"

**~/.workspace/server2.env**

    WORKSPACE_REMOTE_HOST=192.168.50.50
    WORKSPACE_REMOTE_USER=me2
    WORKSPACE_SSH_OPTS="-i ~/.ssh/id_rsa2"
    WORKSPACE_REMOTE_PATH="/srv/workspace"

The following sequence of commands illustrates how to use the `wlogin` shortcut
to conveniently connect to a remote server associated with a project:

    w project1 server1
    wlogin
    ls
    exit

Any additional command line arguments are passed to `ssh`, so you can run
commands remotely like this:

    w server2
    wlogin ls # prints content of /srv/workspace
    
If the remote directory does not exist, it will be created automatically with
`mkdir -p` before the interactive shell or the non-interactive commands are 
executed.

If the remote directory does not exist and you do not have permission to create it,
then if you typed just `wlogin` to get an interactive shell you will see the 
permission denied message and your current directory will be the default home
directory, but if you specified commands after `wlogin ...`, to be safe and avoid
executing them in an unexpected directory, you will see the permission denied message
and the commands will not be  executed at all. In addition, the command will exit
with a non-zero code.

For example, attempting to `wlogin <command>` into a non-existent directory without
permission to create it:

    export WORKSPACE_REMOTE_PATH=/unobtainium
    wlogin pwd
    mkdir: cannot create directory ‘/unobtainium’: Permission denied

    echo $?
    1


## Workspace rsync shortcut

It can be helpful to have a quick command to run rsync from the current directory 
(under a pre-defined workspace) to a remote directory (that is also pre-defined).

The `wsync` command is a simple wrapper around `rsync` that does exactly that. It
relies on variables that are set in the environment:

    WORKSPACE_REMOTE_HOST (hostname or ipaddress; required without default)
    WORKSPACE_REMOTE_USER (to use with ssh login; default is local username)
    WORKSPACE_REMOTE_PATH (remote equivalent of WORKSPACE_PATH; required without default)
    WORKSPACE_PATH (local directory to switch into when entering workspace, used to construct relative path on remote host)
    WORKSPACE_RSYNC_OPTS (customized options for rsync; default is "-crptvzL")
    WORKSPACE_SSH_OPTS (customized options for ssh, should NOT include "-l username"; default is none)

Note that three of these are also used by `wlogin`.

Here is an example workspace definition:

**~/.workspace/project3.env**

    WORKSPACE_REMOTE_HOST=192.168.20.80
    WORKSPACE_REMOTE_USER=me
    WORKSPACE_REMOTE_PATH=workspace
    WORKSPACE_SSH_OPTS="-i ~/.ssh/id_rsa"
    WORKSPACE_RSYNC_OPTS="-crptvzL --delete"
    WORKSPACE_PATH=~/Documents/Projects/Project3
    cd $WORKSPACE_PATH

The following sequence of commands illustrates how the `wsync` shortcut works with `wlogin`:

    w project3
    mkdir -p test && cd test
    touch myfile
    wsync
    wlogin ls test

Expected output:

    myfile

