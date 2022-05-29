# This is only used for publishing to DockerHub
# The site is served via AWS Amplify, not using the container image.
# `docker-compose-dev.yml` uses this to build NGINX
# For local testing, Traefik is preffered, but this will remain if needed.
FROM nginx:alpine

COPY ./dev-knot/public /usr/share/nginx/html