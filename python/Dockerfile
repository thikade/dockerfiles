FROM ubuntu:24.04-local
# FROM python:3.10-slim-bullseye

LABEL MAINTAINER="thikade thomas.hikade@gmail.com"

RUN useradd -u 10789 -m user \
    && mkdir -p /home/user/.config \
    && mkdir -p /home/user/.ansible/collections \
    && chown -R user:user /home/user/

USER 10789

WORKDIR /home/user


# create venvs
RUN python3 -m venv /home/user/env/default
COPY --chown=user:user env/default/requirements.txt     /home/user/env/default/requirements.txt
RUN /home/user/env/default/bin/pip3 -v install -r /home/user/env/default/requirements.txt

# RUN python3 -m venv /home/user/env/ansible
# COPY --chown=user:user env/ansible/requirements.txt   /home/user/env/ansible/requirements.txt
# RUN /home/user/env/ansible/bin/pip3 -v install -r /home/user/env/ansible/requirements.txt

# RUN python3 -m venv /home/user/env/ansiblecore
# COPY --chown=user:user env/ansiblecore/ /home/user/env/ansiblecore/
# RUN /home/user/env/ansiblecore/bin/pip3 -v install -r /home/user/env/ansiblecore/requirements.txt
# RUN /home/user/env/ansiblecore/bin/ansible-galaxy -vvv collection install -r /home/user/env/ansiblecore/requirements.yaml

COPY --chown=user:user ansible.cfg .

RUN chmod -R a+rw /home/user && \
    find /home/user -type d -exec chmod a+rwx {} \;      # required for Openshift random user ID

# # activate default env; same as "source env/default/bin/activate"
ENV PATH=/home/user/env/default/bin:$PATH

CMD [ "sleep", "infinity" ]
