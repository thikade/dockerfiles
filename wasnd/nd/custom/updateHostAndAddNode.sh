#!/bin/bash
#####################################################################################
#                                                                                   #
#  Script to update the Hostname and add the node to deployment manager             #
#                                                                                   #
#  Usage : updateHostAndAddNode.sh                                                  #
#                                                                                   #
#####################################################################################

setEnv()
{
     #Check whether profile name is provided or use default
     if [ "$PROFILE_NAME" = "" ]
     then
          PROFILE_NAME="Custom"
     fi

     #Check whether node name is provided or use default
     if [ "$NODE_NAME" = "" ]
     then
          NODE_NAME="CustomNode"
     fi

     #Check whether dmgr host is provided or use default
     if [ "$DMGR_HOST" = "" ]
     then
         DMGR_HOST="dmgr"
     fi

     #Check whether dmgr port is provided or use default
     if [ "$DMGR_PORT" = "" ]
     then
         DMGR_PORT="8879"
     fi

     #Check whether dmgr port is provided or use default
     if [ "$ADMIN_USER" = "" ]
     then
         ADMIN_USER="wasadmin"
     fi

     #Check whether dmgr port is provided or use default
     if [ "$ADMIN_PASS" = "" ]
     then
         ADMIN_PASS="wasadmin"
     fi

     ADMIN_AUTH="-username $ADMIN_USER -password $ADMIN_PASS"
     #Get the container hostname
     host=`hostname`
     echo "### current hostname = $host"
}

addNodeAndUpdateHostName()
{
     # Add the node
     echo ""
     echo "********* running addNode:"
     /opt/IBM/WebSphere/AppServer/bin/addNode.sh $DMGR_HOST $DMGR_PORT $ADMIN_AUTH

     # Update the hostname
     echo ""
     echo "======================================================================="
     echo "*  update the host name for CustomNode to $host"
     echo "======================================================================="
     /opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython -conntype SOAP $ADMIN_AUTH -host $DMGR_HOST \
     -port $DMGR_PORT -f /work/updateHostName.py CustomNode $host

    touch /work/nodefederated
}

startNode()
{
     # Start the node
     echo "Starting nodeagent.................."
     /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/bin/startNode.sh

     # Exit the container , if nodeagent startup fails
     if [ $? != 0 ]
     then
          echo "NodeAgent startup failed , exiting......"
          LINES=100
          echo "showing $LINES lines of startServer.log :"
          echo "----------------------"
          tail -n $LINES /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/logs/nodeagent/startServer.log
          echo "----------------------"
          exit 1
     fi
}

stopNode()
{
     # Stop the node
     echo "Stopping nodeagent.................."
     /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/bin/stopNode.sh $ADMIN_AUTH

     if [ $? = 0 ]
     then
          echo "NodeAgent stopped successfully."
     fi
}

renameNode()
{
     # rename the node
     echo "*******************************************************************"
     echo "running rename node from CustomNode to: $NODE_NAME "
     echo "*******************************************************************"
     /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/bin/renameNode.sh $DMGR_HOST $DMGR_PORT $NODE_NAME  $ADMIN_AUTH
}

if [ "$WAIT" != "" ] && [ ! -f "/work/nodefederated" ]
then
     sleep $WAIT
fi

setEnv

if [ -d /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/logs/nodeagent ]
then
     echo "******* starting node"
     startNode
else
     echo "******* running: addNodeAndUpdateHostName"
     addNodeAndUpdateHostName
     # Rename and start the node
     if [ $NODE_NAME != "CustomNode" ]
     then
          echo ""
          renameNode
          echo ""
          echo "******* running: startNode"
          startNode
     fi
     echo "NODE RECONFIG COMPLETE!"
fi

trap "stopNode" SIGTERM

sleep 10

while [ -f "/opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/logs/nodeagent/nodeagent.pid" ]
do
    sleep 5
done
