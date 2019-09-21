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

     cat << EOM
     ### current ENV settings ###

     hostName    = $host
     nodeName    = $NODE_NAME
     profileName = $PROFILE_NAME
     dmgrHost    = $DMGR_HOST:$DMGR_PORT

     currently active nodename = $ACTIVE_NODENAME

EOM

}

addNodeAndUpdateHostName()
{
    # Update the hostname
    echo ""
    echo "======================================================================="
    echo "*  addNodeAndUpdateHostName: "
    echo "*      update the node's HOST NAME to: $host"
    echo "======================================================================="
    /opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython -conntype NONE \
          -f /work/updateHostNameBeforeAddNode.py ${ACTIVE_NODENAME} $host

    # Add the node
    echo ""
    echo "======================================================================="
    echo "*  addNodeAndUpdateHostName: "
    echo "*      running addNode"
    echo "======================================================================="
    /opt/IBM/WebSphere/AppServer/bin/addNode.sh $DMGR_HOST $DMGR_PORT $ADMIN_AUTH

    # Update the hostname
    # echo ""
    # echo "======================================================================="
    # echo "*  update the HOST NAME to: $host"
    # echo "======================================================================="
    # /opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython -conntype SOAP $ADMIN_AUTH -host $DMGR_HOST \
    #       -port $DMGR_PORT -f /work/updateHostName.py ${ACTIVE_NODENAME} $host
    #

    touch /work/nodefederated
}

startNode()
{
  echo
  echo "======================================================================="
  echo " syncing Node, then starting NodeAgent ..."
  echo "======================================================================="

  /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/bin/syncNode.sh $DMGR_HOST $DMGR_PORT $ADMIN_AUTH
  # Start the node
  echo "sync complete, Starting nodeagent ..."
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
    echo "======================================================================="
    echo "running rename node from node: $ACTIVE_NODENAME to: $NODE_NAME "
    echo "======================================================================="
    /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/bin/renameNode.sh $DMGR_HOST $DMGR_PORT $NODE_NAME  $ADMIN_AUTH
    echo "$NODE_NAME" > /tmp/nodename
}

if [ "$WAIT" != "" ] && [ ! -f "/work/nodefederated" ]
then
     echo
     echo "STARTUP DELAY! waiting for $WAIT secs!"
     echo
     sleep $WAIT
fi

# get currently configured nodeName
test -f /tmp/nodename && ACTIVE_NODENAME=$(cat /tmp/nodename)
ACTIVE_NODENAME=${ACTIVE_NODENAME:-CustomNode}

setEnv

# if [ -d /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/logs/nodeagent ]
if [ -f /work/nodefederated ]
then
    startNode
else
    addNodeAndUpdateHostName

    # Rename and start the node
    if [ "$NODE_NAME" != "$ACTIVE_NODENAME" ]
    then
      renameNode
    fi

    # startNode

fi

echo
echo "======================================================================="
echo "NODE RECONFIG COMPLETE!"
echo "======================================================================="

trap "stopNode" SIGTERM

sleep 10

while [ -f "/opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/logs/nodeagent/nodeagent.pid" ]
do
    sleep 5
done
