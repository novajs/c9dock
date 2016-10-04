# ------------------------------------------------------------------------------
# Based on a work at https://github.com/docker/docker.
# ------------------------------------------------------------------------------
# Pull base image.
FROM ubuntu
MAINTAINER Jared Allard <jaredallard@outlook.com>

ENV TERM xterm
ENV NVM_DIR /root/.nvm

# ------------------------------------------------------------------------------
# Install base
RUN apt-get update
RUN apt-get install -y build-essential g++ curl libssl-dev apache2-utils git \
libxml2-dev sshfs nano bash wget tmux man-db dialog python sqlite3 libsqlite3-dev

# Install Node.js
RUN curl https://cdn.rawgit.com/creationix/nvm/v0.31.7/install.sh | bash
RUN . ~/.nvm/nvm.sh && nvm install node && nvm alias default node

# ------------------------------------------------------------------------------
# Install Cloud9
RUN echo "Installing C9"
RUN git clone --depth=1  https://github.com/tritonjs/c9.io /cloud9
WORKDIR /cloud9

# Fetch the latest code, w/ busting cache for new builds.
RUN git pull origin master; mkdir /workspace

# Install cloud9 sdk.
RUN . ~/.nvm/nvm.sh; nvm use node; /cloud9/scripts/install-sdk.sh; npm install -g pm2

# Tweak standlone.js conf
RUN sed -i -e 's_127.0.0.1_0.0.0.0_g' /cloud9/configs/standalone.js

# Modify config
ADD conf/standalone.js /cloud9/settings/standalone.js
ADD fetch-init.sh /root/fetch-init.sh
ADD HOME_.c9/user.settings /root/.c9/user.settings

#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ------------------------------------------------------------------------------
# Setup DevOps aspects.
EXPOSE 80
EXPOSE 3000

# ------------------------------------------------------------------------------
# Set entrypoint to INIT.
ENTRYPOINT ["/bin/bash", "--login", "-c", "cd /root; bash fetch-init.sh"]
