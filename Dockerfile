FROM klakegg/hugo:ext-ubuntu as base

WORKDIR /usr/src/app

COPY ./dev-knot .
