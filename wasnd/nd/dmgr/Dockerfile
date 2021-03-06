ARG WAS_INSTALLATION_VERSION
FROM wasnd-noprofile:${WAS_INSTALLATION_VERSION}

# based on https://github.com/WASdev/ci.docker.websphere-traditional/
LABEL AUTHOR thikade <thomas.hikade@gmail.com>

ARG PROFILE_NAME=Dmgr01
ARG CELL_NAME=DefaultCell01

### DO NOT CHANGE hostname 'localhost' or node name at build time!
### Hostname will be changed by container ENTRYPOINT/CMD script!
### using the container's real hostname
ENV NODE_NAME=ManagerNode
ENV HOST_NAME=localhost
ENV PROFILE_NAME=$PROFILE_NAME
ENV PATH /opt/IBM/WebSphere/AppServer/bin:$PATH

EXPOSE 9060 9043 9809 8879 9632 9401 9403 9402 9100 7277 9352 5555 7060 11005 11006 9420

COPY startDmgr.sh update*.py /work/

RUN echo "$NODE_NAME" > /tmp/nodename && \
  echo "$HOST_NAME" > /tmp/hostname

# Create Deployment Manager profile
RUN echo "NODE_NAME=$NODE_NAME" && \
  echo "CELL_NAME=$CELL_NAME" && \
  echo "HOST_NAME=$HOST_NAME" && \
  echo "PROFILE_NAME=$PROFILE_NAME" && \
  /opt/IBM/WebSphere/AppServer/bin/manageprofiles.sh -create -templatePath \
  /opt/IBM/WebSphere/AppServer/profileTemplates/management -profileName $PROFILE_NAME \
  -profilePath /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME  -serverType DEPLOYMENT_MANAGER \
  -cellName $CELL_NAME -nodeName $NODE_NAME -disableWASDesktopIntegration -hostName $HOST_NAME \
  -enableAdminSecurity true -adminUserName wasadmin -adminPassword wasadmin


RUN /opt/IBM/WebSphere/AppServer/bin/startManager.sh

USER root
RUN ln -s /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME           /PROF  && \
  ln -s /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/logs/dmgr   /LOGS

USER $WAS_USER
CMD ["bash", "/work/startDmgr.sh"]
