
FROM alpine:3.24

USER root

RUN apk add --no-cache apache2 \
    && addgroup -S -g 10001 nexvion \
    && adduser -S -D -H -u 10001 -G nexvion nexvion \
    && mkdir -p /var/www/localhost/htdocs \
    && chown -R nexvion:nexvion /var/www/localhost/htdocs \
    && sed -i 's/^Listen 80$/Listen 8080/' /etc/apache2/httpd.conf \
    && sed -i 's#^ServerRoot "/var/www"#ServerRoot "/etc/apache2"#' /etc/apache2/httpd.conf \
    && sed -i 's#^PidFile /run/apache2/httpd.pid#PidFile /tmp/httpd.pid#' /etc/apache2/conf.d/mpm.conf 2>/dev/null || true

COPY --chown=10001:10001 . /var/www/localhost/htdocs/

USER 10001:10001

EXPOSE 8080

CMD ["httpd", "-D", "FOREGROUND"]
