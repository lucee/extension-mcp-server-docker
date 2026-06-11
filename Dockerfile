FROM lucee/lucee:7.1.0.169-SNAPSHOT

COPY lucee-config.json /opt/lucee/server/lucee-server/context/.CFConfig.json
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
