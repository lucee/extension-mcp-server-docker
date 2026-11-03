# Base image and extension versions can be overridden with --build-arg.
ARG LUCEE_IMAGE=lucee/lucee:7.1.1.17-light

FROM --platform=linux/amd64 ${LUCEE_IMAGE}

ARG MCP_SERVER_VERSION=1.0.1.6
ARG LUCENE_SEARCH_VERSION=3.0.0.163
ARG ESAPI_VERSION=3.0.0.14
ARG MAVEN_REPOSITORY=https://repo1.maven.org/maven2
# set to "false" to skip building the documentation search index at build time
ARG PREBUILD_SEARCH_INDEX=true

RUN mkdir -p /var/www
COPY www/ /var/www/

COPY lucee-config.json /opt/lucee/server/lucee-server/context/.CFConfig.json
COPY Server.cfc /opt/lucee/server/lucee-server/context/context/Server.cfc
COPY docker-entrypoint.sh prepare-image.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh /usr/local/bin/prepare-image.sh

# Download the extensions at build time, so a new container does not need to fetch anything on startup.
RUN mkdir -p /opt/lucee/server/lucee-server/deploy \
	&& cd /opt/lucee/server/lucee-server/deploy \
	&& wget -q "${MAVEN_REPOSITORY}/org/lucee/mcp-server-extension/${MCP_SERVER_VERSION}/mcp-server-extension-${MCP_SERVER_VERSION}.lex" \
	&& wget -q "${MAVEN_REPOSITORY}/org/lucee/lucene-search-extension/${LUCENE_SEARCH_VERSION}/lucene-search-extension-${LUCENE_SEARCH_VERSION}.lex" \
	&& wget -q "${MAVEN_REPOSITORY}/org/lucee/esapi-extension/${ESAPI_VERSION}/esapi-extension-${ESAPI_VERSION}.lex"

# Start Lucee once at build time: installs the extensions, compiles the templates
# and (optionally) builds the documentation search index.
RUN PREBUILD_SEARCH_INDEX="${PREBUILD_SEARCH_INDEX}" /usr/local/bin/prepare-image.sh

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
