# ------------------------------------------------------------------------------
# Based on a work at https://github.com/docker/docker.
# ------------------------------------------------------------------------------
# Pull base image.
FROM ubuntu
MAINTAINER Jared Allard <jaredallard@outlook.com>

ENV TERM xterm

# ------------------------------------------------------------------------------
# Install base
RUN apt-get update
RUN apt-get install -y build-essential g++ curl libssl-dev apache2-utils git \
libxml2-dev sshfs nano bash

# ------------------------------------------------------------------------------
# User space installs
RUN apt-get install -y wget tmux zsh
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh; cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc; chsh -s /bin/zsh
RUN echo "exec zsh" >> /root/.bashrc

# Install Node.js
RUN curl https://cdn.rawgit.com/creationix/nvm/v0.31.7/install.sh | bash
ENV NVM_DIR /root/.nvm
RUN . ~/.nvm/nvm.sh && nvm install node && nvm alias default node

# ------------------------------------------------------------------------------
# Install Cloud9
RUN git clone --depth=1  https://github.com/tritonjs/c9.io /cloud9
WORKDIR /cloud9

# Fetch the latest code, w/ busting cache for new builds.
RUN _=$(date) git fetch origin
RUN git pull

# Install cloud9 sdk.
RUN apt-get install -y python
RUN . ~/.nvm/nvm.sh; nvm use node; /cloud9/scripts/install-sdk.sh

# Tweak standlone.js conf
RUN sed -i -e 's_127.0.0.1_0.0.0.0_g' /cloud9/configs/standalone.js

# Modify config
ADD conf/standalone.js /cloud9/settings/standalone.js

# Copy the INIT.
ADD fetch-init.sh /root/fetch-init.sh

# ------------------------------------------------------------------------------
# Add volumes
RUN mkdir /workspace
VOLUME /workspace

# ------------------------------------------------------------------------------
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ------------------------------------------------------------------------------
# Setup DevOps aspects.
EXPOSE 80
EXPOSE 3000

# Install PM2
RUN . ~/.nvm/nvm.sh; npm install -g pm2

# Add User settings
ADD HOME_.c9/user.settings /root/.c9/user.settings

# ------------------------------------------------------------------------------
# Set entrypoint to INIT.
ENTRYPOINT ["/bin/bash", "--login", "-c", "cd /root; bash fetch-init.sh"]
