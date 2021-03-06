ARG WAS_INSTALLATION_VERSION
FROM wasnd-noprofile:${WAS_INSTALLATION_VERSION}

# based on https://github.com/WASdev/ci.docker.websphere-traditional/
LABEL AUTHOR thikade <thomas.hikade@gmail.com>

ARG PROFILE_NAME=Custom
ARG CELL_NAME=CustomCell
ARG NODE_NAME=CustomNodeXX

### DO NOT change hostname or node name!
### They will be re-set from container startup script
ENV NODE_NAME=$NODE_NAME
ENV HOST_NAME=localhost
ENV PROFILE_NAME=$PROFILE_NAME
ENV PATH /opt/IBM/WebSphere/AppServer/bin:$PATH

EXPOSE 2809 9402 9403 9353 9633 9100 11004 11003 9401 7276 7286 5558 5578 5060 5061 8880 9060 9043 9080 9443

COPY *.sh *.py /work/

RUN echo "$NODE_NAME" > /tmp/nodename && \
  echo "$HOST_NAME" > /tmp/hostname

# Create default Custom Node profile
RUN echo "\nNODE_NAME=$NODE_NAME" && \
  echo "CELL_NAME=$CELL_NAME" && \
  echo "HOST_NAME=$HOST_NAME" && \
  echo "PROFILE_NAME=$PROFILE_NAME\n" && \
  /opt/IBM/WebSphere/AppServer/bin/manageprofiles.sh -create -templatePath \
  /opt/IBM/WebSphere/AppServer/profileTemplates/managed -profileName $PROFILE_NAME \
  -profilePath /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME -cellName $CELL_NAME \
  -nodeName $NODE_NAME -disableWASDesktopIntegration -FederateLater true -hostName $HOST_NAME

USER root
RUN ln -s /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME           /PROF  && \
  ln -s /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/logs      /LOGS

USER $WAS_USER

CMD ["/work/updateHostAndAddNode.sh"]
