FROM ubuntu:24.04-local
# FROM python:3.10-slim-bullseye

LABEL MAINTAINER="thikade thomas.hikade@gmail.com"

RUN useradd -u 10789 -m user1 \
    && mkdir -p /home/user1/.config \
    && mkdir -p /home/user1/.ansible/collections \
    && chown -R user1:user1 /home/user1/

USER 10789

WORKDIR /home/user1


# create venvs
RUN python3 -m venv /home/user1/env/default
COPY --chown=user1:user1 env/default/requirements.txt     /home/user1/env/default/requirements.txt
RUN /home/user1/env/default/bin/pip3 -v install -r /home/user1/env/default/requirements.txt

RUN python3 -m venv /home/user1/env/ansible
COPY --chown=user1:user1 env/ansible/requirements.txt   /home/user1/env/ansible/requirements.txt
RUN /home/user1/env/ansible/bin/pip3 -v install -r /home/user1/env/ansible/requirements.txt

RUN python3 -m venv /home/user1/env/ansiblecore
COPY --chown=user1:user1 env/ansiblecore/ /home/user1/env/ansiblecore/
RUN /home/user1/env/ansiblecore/bin/pip3 -v install -r /home/user1/env/ansiblecore/requirements.txt
RUN /home/user1/env/ansiblecore/bin/ansible-galaxy -vvv collection install -r /home/user1/env/ansiblecore/requirements.yaml

COPY --chown=user1:user1 ansible.cfg .

# # activate default env; same as "source env/default/bin/activate"
ENV PATH=/home/user1/env/default/bin:$PATH

CMD [ "sleep", "infinity" ]
