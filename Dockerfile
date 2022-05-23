FROM klakegg/hugo:0.93.2 as hugo

ENV LETSENCRYPT_DOMAIN ${LETSENCRYPT_DOMAIN}
ENV LETSENCRYPT_EMAIL ${LETSENCRYPT_EMAIL}

COPY ./dev-knot /usr/src/app

WORKDIR /usr/src/app

RUN hugo --config ./config.toml

FROM nginx:alpine

#Copy static files to Nginx
COPY ./default.conf /etc/nginc/conf.d/default.conf

WORKDIR /usr/share/nginx/html