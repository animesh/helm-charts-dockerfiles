#!/bin/bash
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

set -e

cmd="/opt/conda/bin/jupyter lab --config $NOTEBOOKS_CONFIG_DIR/jupyter_notebook_config.py --ip 0.0.0.0 --port 8888"

# Handle special flags if we're root
if [ $(id -u) == 0 ] ; then

    # Handle username change. Since this is cheap, do this unconditionally
    echo "Set username to: $NB_USER"
    usermod -d /home/$NB_USER -l $NB_USER jovyan

    # Handle case where provisioned storage does not have the correct permissions by default
    # Ex: default NFS/EFS (no auto-uid/gid)
    if [[ "$CHOWN_HOME" == "1" || "$CHOWN_HOME" == 'yes' ]]; then
        echo "Changing ownership of /home/$NB_USER to $NB_UID:$NB_GID"
        chown $NB_UID:$NB_GID /home/$NB_USER
    fi

    # handle home and working directory if the username changed
    if [[ "$NB_USER" != "jovyan" ]]; then
        # changing username, make sure homedir exists
        # (it could be mounted, and we shouldn't create it if it already exists)
        if [[ ! -e "/home/$NB_USER" ]]; then
            echo "Relocating home dir to /home/$NB_USER"
            mv /home/jovyan "/home/$NB_USER"
        fi
        # if workdir is in /home/jovyan, cd to /home/$NB_USER
        if [[ "$PWD/" == "/home/jovyan/"* ]]; then
            newcwd="/home/$NB_USER/${PWD:13}"
            echo "Setting CWD to $newcwd"
            cd "$newcwd"
        fi
    fi

    # Change UID of NB_USER to NB_UID if it does not match
    if [ "$NB_UID" != $(id -u $NB_USER) ] ; then
        echo "Set $NB_USER UID to: $NB_UID"
        usermod -u $NB_UID $NB_USER
    fi

    # Change GID of NB_USER to NB_GID if it does not match
    if [ "$NB_GID" != $(id -g $NB_USER) ] ; then
        echo "Set $NB_USER GID to: $NB_GID"
        groupmod -g $NB_GID -o $(id -g -n $NB_USER)
    fi

    # Enable sudo if requested
    if [[ "$GRANT_SUDO" == "1" || "$GRANT_SUDO" == 'yes' ]]; then
        echo "Granting $NB_USER sudo access and appending $CONDA_DIR/bin to sudo PATH"
        echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
    fi

    # Exec the command as NB_USER with the PATH and the rest of
    # the environment preserved

    echo "Executing the command: $cmd"
    export PATH=$PATH
    exec sudo -E -H -u $NB_USER PATH=$PATH $cmd
else
    if [[ ! -z "$NB_UID" && "$NB_UID" != "$(id -u)" ]]; then
        echo 'Container must be run as root to set $NB_UID'
    fi
    if [[ ! -z "$NB_GID" && "$NB_GID" != "$(id -g)" ]]; then
        echo 'Container must be run as root to set $NB_GID'
    fi
    if [[ "$GRANT_SUDO" == "1" || "$GRANT_SUDO" == 'yes' ]]; then
        echo 'Container must be run as root to grant sudo permissions'
    fi

    # Execute the command
    echo "Executing the command: $cmd"
    exec $cmd
fi