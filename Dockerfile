FROM --platform=linux/amd64 lucee/lucee:8.0.0.163-SNAPSHOT-light

RUN mkdir -p /var/www
COPY www/ /var/www/

COPY lucee-config.json /opt/lucee/server/lucee-server/context/.CFConfig.json
COPY Server.cfc /opt/lucee/server/lucee-server/context/context/Server.cfc
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
