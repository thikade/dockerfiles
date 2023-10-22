FROM python:3.11-alpine

ENV USER=ansible UID=12345 GID=12345
ENV HOME /home/$USER/env/ansible
ENV ANSIBLE_CONFIG $HOME/playbook/ansible.cfg

WORKDIR $HOME

RUN apk add --update --no-cache curl bash openssh git && \
    rm -rf /var/cache/apk/* && \
    addgroup --gid "$GID"  "$USER" && \
    adduser  --disabled-password \
        --gecos "ansible execution user" --home "$(pwd)" --no-create-home \
        --uid "$UID" --ingroup "$USER"  "$USER" && \
    mkdir -p $HOME && \
    chown -R $USER:$USER $HOME
    # && \
    # chmod -R ugo+rw $HOME && \
    # find $HOME -type d -exec chmod ugo+rwx {} \;      # required for Openshift random user ID

USER $UID

COPY --chown=$USER:$USER requirements.yaml requirements.txt $HOME/

RUN python3 -m venv $HOME && \
    $HOME/bin/pip3 -v install -r $HOME/requirements.txt && \
    $HOME/bin/ansible-galaxy install -r $HOME/requirements.yaml && \
    chmod -R a+rw $HOME && \
    find $HOME -type d -exec chmod a+rwx {} \;      # required for Openshift random user ID

# COPY --chown=$USER:$USER ansible.cfg playbook/ $HOME/playbook/

# # activate default env; same as "source env/<ENV>/bin/activate"
ENV PATH $HOME/bin:$PATH

ENTRYPOINT []
CMD ["ansible", "--version"]
