ARG NODE_VERSION=14-alpine
FROM node:${NODE_VERSION}

RUN apk add --no-cache make pkgconfig gcc g++ python3 libx11-dev libxkbfile-dev libsecret-dev

WORKDIR /home/ide
ADD latest.package.json ./package.json

RUN yarn install

# install theia globally
RUN npm i -g theia

ENV NODE_OPTIONS="--max_old_space_size=4096"
RUN npx theia build

RUN npx theia download:plugins

RUN yarn --production && \
    yarn autoclean --init && \
    echo *.ts >> .yarnclean && \
    echo *.ts.map >> .yarnclean && \
    echo *.spec.* >> .yarnclean && \
    yarn autoclean --force && \
    yarn cache clean

FROM node:${NODE_VERSION}

# Env variables
ENV HOME=/home/bb \
    SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/home/ide/plugins \
    USE_LOCAL_GIT=true \
    TINI_KILL_PROCESS_GROUP=1
    
# Whenever possible, install tools using the distro package manager
RUN apk add --no-cache git openssh bash libsecret tini jq curl socat

# Add user
RUN addgroup bb && \
    adduser -G bb -s /bin/sh -D bb && \
    chmod g+rw /home && \
# Setup folders
    mkdir -p /home/ide && \
    mkdir -p /home/bb/workspace && \
    mkdir -p /home/bb/.m2 && \
    mkdir -p /home/bb/.theia && \
    chown -R bb:bb /home/bb && \
# Configure a nice terminal
    echo "export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" >> /home/bb/.bashrc && \
# Fake poweroff (stops the container from the inside by sending SIGHUP to PID 1)
    echo "alias poweroff='kill -1 1'" >> /home/bb/.bashrc && \
# Setup an initial workspace
    echo '{"recentRoots":["file:///home/bb/workspace"]}' > /home/bb/.theia/recentworkspace.json && \
# Setup settings (file icons theme)
    echo '{"workbench.iconTheme": "vs-seti"}' > /home/bb/.theia/settings.json

# Copy files from previous stage 
COPY --from=0 --chown=bb:bb /home/ide /home/ide

# Use tini 
ENTRYPOINT ["/sbin/tini", "--"]

# Running environment
EXPOSE 3030
WORKDIR /home/bb/workspace
USER bb
CMD [ "node", "/home/ide/src-gen/backend/main.js", "--hostname=0.0.0.0", "--port=3030" ]