#!/bin/bash
#####################################################################################
#                                                                                   #
#  Script to start the WebSphere extreme scale standalone server
#                                                                                   #
#  Usage : starWxs.sh <cmd1> [<cmd2> [<cmd3>]...] #
#                                                                                   #
#####################################################################################

#
# Sleep to ensure other wxs containers are up as well
sleep 30

while [[ $# -gt 0 ]]
  do
    cmd2run=${1}
    echo "Executing startup cmd: \"${cmd2run}\""
    eval ${cmd2run} || {
        echo "ERROR! Running command ${cmd2run} failed! Container might not be functional"
    }
    shift
  done

sleep infinity &
WPPID=$!

wait ${WPPID}

exit 0
