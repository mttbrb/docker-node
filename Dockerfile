# Dockerfile

FROM debian:jessie

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ENV appDir  /var/www/app/current

RUN apt-get update

RUN apt-get install -y -q --no-install-recommends \
    apt-transport-https \
    build-essential \
    ca-certificates \
    curl \
    g++ \
    gcc \
    git \
    make \
    nginx \
    sudo \
    wget \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get -y autoclean

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 5.1.0

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.26.0/install.sh | bash \
    && source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN mkdir -p /var/www/app/current
WORKDIR ${appDir}

ADD package.json ./
RUN npm i --production

RUN npm i -g pm2

ADD . /var/www/app/current

EXPOSE 4500

CMD ["pm2", "start", "processes.json", "--no-daemon"]
# the --no-daemon is a minor workaround to prevent the docker container from thinking pm2 has stopped running and ending itself
