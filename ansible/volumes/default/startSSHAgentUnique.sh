SSH_ENV=$HOME/.ssh/environment
PRIVATE_KEY=$1
PRIVATE_KEY_NAME=$2

function start_agent {
     echo "Initialising new SSH agent..."
     /usr/bin/ssh-agent | sed 's/^echo/#echo/' > ${SSH_ENV}
     echo succeeded
     chmod 600 ${SSH_ENV}
     . ${SSH_ENV} > /dev/null
     /usr/bin/ssh-add;
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
     . ${SSH_ENV} > /dev/null
     #ps ${SSH_AGENT_PID} doesn't work under cywgin
     ps -efp ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
         start_agent;
     }
else
     start_agent;
fi
if  ssh-add -l | grep "${PRIVATE_KEY_NAME}" > /dev/null ; then
   # do nothing
   :
else
   ssh-add ${PRIVATE_KEY}
fi
