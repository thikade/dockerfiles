FROM ibmcom/websphere-traditional:9.0.0.11

ARG ADMIN_PASSWORD=wasadmin
ENV ADMIN_PASSWORD=${ADMIN_PASSWORD}

# enforce the password specified in the env variable and start WAS!
CMD echo -n ${ADMIN_PASSWORD} > /tmp/PASSWORD && exec bash /work/start_server.sh
