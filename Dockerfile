FROM node:17-alpine

WORKDIR /app

COPY package.json package-lock.json /app/

RUN npm install hexo-cli make -g
RUN npm cache clean --force && npm config set strict-ssl false
RUN rm -rf node_modules && npm install --force
RUN set -x \
    && . /etc/os-release \
    && case "$ID" in \
        alpine) \
            apk add --no-cache bash git openssh \
            ;; \
        debian) \
            apt-get update \
            && apt-get -yq install bash git openssh-server \
            && apt-get -yq clean \
            && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
            ;; \
    esac \
    && yarn bin || ( npm install --global yarn && npm cache clean ) \
    && git --version && bash --version && ssh -V && npm -v && node -v && yarn -vclear