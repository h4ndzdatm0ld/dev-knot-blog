FROM klakegg/hugo as hugo

COPY ./dev-knot /usr/src/app

WORKDIR /usr/src/app

RUN hugo --config ./config.toml

FROM nginx:alpine

#Copy static files to Nginx
COPY ./default.conf /etc/nginc/conf.d/default.conf

WORKDIR /usr/share/nginx/html