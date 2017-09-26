From alpine:latest
Maintainer thomas.hikade@gmail.com


# ADD https://github.com/mholt/caddy/releases/download/v0.10.9/caddy_v0.10.9_linux_amd64.tar.gz /
ADD caddy_bin/caddy_v0.10.9_linux_amd64 /

ADD Caddyfile /

RUN mkdir /data
ADD some_index.html /data

ENV HTTP_PORT=8080

EXPOSE $HTTP_PORT

CMD [ "/caddy", "-conf", "/Caddyfile" ]
