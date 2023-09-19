ARG NODE_VERSION=18-bookworm-slim
FROM node:${NODE_VERSION}

# Install necessary packages
RUN apt-get update && \
    apt-get install -y make pkg-config gcc g++ python3 libx11-dev libxkbfile-dev libsecret-1-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /home/ide

# Add package.json
ADD package.json ./package.json

# Set environment variables
ENV NODE_OPTIONS="--max_old_space_size=4096"
RUN yarn install

# install theia globally
RUN yarn theia build

RUN npx theia download:plugins

# Install dependencies and build Theia
RUN yarn --production && \
    yarn autoclean --init && \
    echo *.ts >> .yarnclean && \
    echo *.ts.map >> .yarnclean && \
    echo *.spec.* >> .yarnclean && \
    yarn autoclean --force && \
    yarn cache clean

# Stage 2
FROM node:${NODE_VERSION}

# Env variables
ENV HOME=/root \
    SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/home/ide/plugins \
    USE_LOCAL_GIT=true

# Whenever possible, install tools using the distro package manager
RUN apt-get update && \
    apt-get install -y git openssh-client bash libsecret-1-0 jq curl socat && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create necessary directories and configure terminal
RUN mkdir -p /root/workspace && \
    mkdir -p /root/ide && \
    mkdir -p /root/.theia && \
    mkdir -p /root/mock && \
    # Configure a nice terminal
    # format-1 is: root@6f3ecd3d6a6b:~/workspace$ 
    # echo "export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" >> /root/.bashrc && \
    # format-1 is: root ~/workspace $ 
    echo "export PS1='\[\033[01;32m\]\u \[\033[01;34m\]\w\[\033[00m\] \$ '" >> /root/.bashrc && \
    # Fake poweroff (stops the container from the inside by sending SIGHUP to PID 1)
    echo "alias poweroff='kill -1 1'" >> /root/.bashrc && \
    # Setup an initial workspace
    echo '{"recentRoots":["file:///root/workspace"]}' > /root/.theia/recentworkspace.json && \
    # Setup settings (file icons theme)
    echo '{"workbench.iconTheme": "vs-seti", "editor.mouseWheelZoom": true }' > /root/.theia/settings.json

# Copy files from previous stage 
COPY --from=0 /home/ide /root/ide

## ADD CUSTOM IMPLEMENTATION

# PostgreSQL installation and configuration
RUN apt-get update \
    && apt-get install -y postgresql postgresql-contrib \
    && echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/$(ls /etc/postgresql)/main/pg_hba.conf \
    && echo "listen_addresses='*'" >> /etc/postgresql/$(ls /etc/postgresql)/main/postgresql.conf

# Add custom files
ADD motd /root/workspace/motd

# Running environment
EXPOSE 3030
RUN mkdir -p /home/mock
WORKDIR /root/workspace
USER root
COPY ./data /home/mock
COPY ./init.sql /home/mock/init.sql
COPY ./entrypoint.sh /root
RUN chmod +x /root/entrypoint.sh
RUN chown -R postgres:postgres /home/mock
ENTRYPOINT [ "/root/entrypoint.sh" ]
