# linux-workspace

This package installs an alias `w` that makes it easy to define and use
multiple workspaces. The workspaces are defined as `.env` files in the
`~/.workspace` directory. Type `w <name>` (without the `.env` extension)
to switch to that workspace, which means source the content of the `.env`
file to the current shell. 

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

