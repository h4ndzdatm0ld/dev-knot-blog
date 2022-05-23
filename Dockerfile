# FROM klakegg/hugo:0.93.2 as hugo

# ENV LETSENCRYPT_DOMAIN ${LETSENCRYPT_DOMAIN}
# ENV LETSENCRYPT_EMAIL ${LETSENCRYPT_EMAIL}
# FROM nginx:alpine
# COPY ./dev-knot /usr/src/app

# WORKDIR /usr/src/app

# RUN hugo --config ./config.toml

# FROM nginx:alpine
# COPY public /usr/share/nginx/html

# #Copy static files to Nginx
# COPY ./default.conf /etc/nginc/conf.d/default.conf

# WORKDIR /usr/share/nginx/html

# Lets keep it simple
FROM nginx:alpine
COPY ./dev-knot/public /usr/share/nginx/html