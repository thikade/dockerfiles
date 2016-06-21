#!/bin/bash

# kudos to Marek Goldmann 
# https://goldmann.pl/blog/2014/07/23/customizing-the-configuration-of-the-wildfly-docker-image/#_using_code_jboss_cli_sh_code

JBOSS_HOME=/opt/jboss/wildfly
JBOSS_CLI=$JBOSS_HOME/bin/jboss-cli.sh
JBOSS_MODE=${1:-"standalone"}
JBOSS_CONFIG=${2:-"$JBOSS_MODE.xml"}

function wait_for_server() {
  until `$JBOSS_CLI -c "ls /deployment" &> /dev/null`; do
    sleep 1
  done
}

echo "=> Starting WildFly server"
$JBOSS_HOME/bin/$JBOSS_MODE.sh -c $JBOSS_CONFIG >/dev/null &

# echo "IP = ${RSYSLOG_IP}"
echo "=> Waiting for the server to boot"
wait_for_server

echo "=> Executing the commands"
# $JBOSS_CLI -c --file=`dirname "$0"`/commands.cli
$JBOSS_CLI -c --file=/home/jboss/commands.cli

echo "=> Shutting down WildFly"
if [ "$JBOSS_MODE" = "standalone" ]; then
  $JBOSS_CLI -c ":shutdown"
else
  $JBOSS_CLI -c "/host=*:shutdown"
fi