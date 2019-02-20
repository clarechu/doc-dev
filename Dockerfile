FROM docker.vpclub.cn/hidevopsio/base-nodejs:8.12-alpine-0.0.1

COPY _book /usr/src/app/_book

WORKDIR /usr/src/app

USER 1001

CMD ["http-server", "_book"]

