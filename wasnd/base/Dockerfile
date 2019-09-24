FROM ibmcom/websphere-traditional:9.0.0.11

ARG ADMIN_PASSWORD=wasadmin
ENV ADMIN_PASSWORD=${ADMIN_PASSWORD}

USER root
RUN apt-get -y -qq update &&  apt-get install -qq -y unzip wget net-tools sudo less vim curl netcat inetutils-ping iproute2

USER was

# enforce the password specified in the env variable and start WAS!
CMD echo -n ${ADMIN_PASSWORD} > /tmp/PASSWORD && exec bash /work/start_server.sh
