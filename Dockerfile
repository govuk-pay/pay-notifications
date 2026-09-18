FROM alpine:3.24.2@sha256:31b6477333eb8257db9e5d7c3a7264fd0467928756f0bbcc27d35bea5d28cdbd

RUN apk -U upgrade --available

USER root

RUN apk --no-cache add \
    openssl \
    tini \
    nginx~=1.30.4 \
    nginx-mod-http-geoip~=1.30.4

RUN install -d /etc/nginx/ssl

# forward request and error logs to docker log collector
RUN openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048 &>/dev/null \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

RUN install -d /app
COPY src/docker-startup.sh /app
COPY src/files/authorized_ip /etc/nginx/
COPY src/files/sites.nginx /etc/nginx/conf.d/notifications.conf
COPY src/files/nginx_conf /etc/nginx/nginx.conf

EXPOSE 443

WORKDIR /app

ENTRYPOINT ["tini", "--"]

CMD ["./docker-startup.sh"]
