FROM klakegg/hugo:latest as base

WORKDIR /usr/src/app

COPY ./dev-knot .
