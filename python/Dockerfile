FROM ubuntu:22.04-local
# FROM python:3.10-slim-bullseye

LABEL MAINTAINER thikade "thomas.hikade@gmail.com"

RUN useradd -u 1000 -m user1 \
    && mkdir -p /home/user1/.config \
    && mkdir -p /home/user1/.ansible/collections \
    && chown -R user1:user1 /home/user1/

USER user1

WORKDIR /home/user1


# create venvs
RUN python3 -m venv /home/user1/env/default
COPY --chown=user1:user1 env/default/requirements.txt     /home/user1/env/default/requirements.txt
RUN /home/user1/env/default/bin/pip3 -v install -r /home/user1/env/default/requirements.txt

RUN python3 -m venv /home/user1/env/ansible29
COPY --chown=user1:user1 env/ansible29/requirements.txt   /home/user1/env/ansible29/requirements.txt
RUN /home/user1/env/ansible29/bin/pip3 -v install -r /home/user1/env/ansible29/requirements.txt

RUN python3 -m venv /home/user1/env/ansiblecore
COPY --chown=user1:user1 env/ansiblecore/ /home/user1/env/ansiblecore/
RUN /home/user1/env/ansiblecore/bin/pip3 -v install -r /home/user1/env/ansiblecore/requirements.txt
RUN /home/user1/env/ansiblecore/bin/ansible-galaxy -vvv collection install -r /home/user1/env/ansiblecore/requirements.yaml 

COPY --chown=user1:user1 ansible.cfg .

# # activate default env; same as "source env/default/bin/activate"
ENV PATH /home/user1/env/default/bin:$PATH

CMD sleep infinity
