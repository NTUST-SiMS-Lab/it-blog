FROM node:17-alpine

RUN npm install hexo-cli -g
# RUN npm install hexo-theme-icarus
# RUN npm install make -g
# RUN npm install -g sass

# RUN set -x \
#     && . /etc/os-release \
#     && case "$ID" in \
#         alpine) \
#             apk add --no-cache bash git openssh \
#             ;; \
#         debian) \
#             apt-get update \
#             && apt-get -yq install bash git openssh-server \
#             && apt-get -yq clean \
#             && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
#             ;; \
#     esac \
#     && yarn bin || ( npm install --global yarn && npm cache clean ) \
#     && git --version && bash --version && ssh -V && npm -v && node -v && yarn -v