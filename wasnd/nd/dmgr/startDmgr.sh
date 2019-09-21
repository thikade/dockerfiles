#!/bin/bash
#####################################################################################
#                                                                                   #
#  Script to start the Deployment Manager                                           #
#                                                                                   #
#  Usage : startDmgr.sh                                                             #
#                                                                                   #
#####################################################################################

update_host_node_name()
{
    #Get the container hostname
    host=`hostname`

    #Check whether node name is provided or use default
    if [ "$NODE_NAME" != "$ACTIVE_NODENAME" ]
    then
       # Update the nodename
       echo "======================================================================="
       echo "running rename node from node: $ACTIVE_NODENAME to: $NODE_NAME "
       echo "======================================================================="
       /opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython -conntype NONE -f /work/updateNodeName.py \
       $ACTIVE_NODENAME $NODE_NAME

       echo "WAS_NODE=$NODE_NAME" >> /opt/IBM/WebSphere/AppServer/bin/setupCmdLine.sh
       echo "$NODE_NAME" > /tmp/nodename

    fi

    # Update the hostname
    echo ""
    echo "======================================================================="
    echo "*  update the HOST NAME to: $host"
    echo "======================================================================="
    /opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython -conntype NONE -f /work/updateHostName.py \
    $NODE_NAME $host

    touch /work/host_nodenameupdated
}

startDmgr()
{
    if [ "$PROFILE_NAME" = "" ]
    then
        PROFILE_NAME="Dmgr01"
    fi

    echo "Starting deployment manager ............"
    /opt/IBM/WebSphere/AppServer/bin/startManager.sh

    if [ $? != 0 ]
    then
        echo " Dmgr startup failed , exiting....."
        LINES=100
        echo "showing $LINES lines of startServer.log :"
        echo "----------------------"
        tail -n $LINES /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/logs/dmgr/startServer.log
        echo "----------------------"
        exit 1
    fi
}

stopDmgr()
{
    if [ "$PROFILE_NAME" = "" ]
    then
        PROFILE_NAME="Dmgr01"
    fi

    echo "Stopping deployment manager ............"
    /opt/IBM/WebSphere/AppServer/bin/stopManager.sh

    if [ $? = 0 ]
    then
        echo " Dmgr stopped successfully. "
    fi
}

#Get the container hostname
host=`hostname`

# get configured nodeName
test -f /tmp/nodename && ACTIVE_NODENAME=$(cat /tmp/nodename)
ACTIVE_NODENAME=${ACTIVE_NODENAME:-CustomNode}

cat << EOM
### current ENV settings ###

hostName    = $host
nodeName    = $NODE_NAME
profileName = $PROFILE_NAME

currently active nodename = $ACTIVE_NODENAME

EOM

if [ ! -f "/work/host_nodenameupdated" ]
then
    update_host_node_name
fi

startDmgr
echo "DMGR SETUP COMPLETE"
trap "stopDmgr" SIGTERM

sleep 10

while [ -f "/opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/logs/dmgr/dmgr.pid" ]
do
    sleep 5
done
