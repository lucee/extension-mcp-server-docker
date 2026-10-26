# Lucee MCP Server — Docker

Minimal Docker image running Lucee 7.1 (light) with the [MCP Server extension](https://github.com/lucee/extension-mcp-server). `GET /` serves a landing page explaining the endpoint and its tools; `POST /` is the MCP JSON-RPC endpoint.

This image installs the Lucene Search extension so `search_lucee_docs` can index and search Lucee documentation (functions, tags, and recipes).

## Quick Start

```bash
git clone https://github.com/lucee/extension-mcp-server-docker.git
cd extension-mcp-server-docker
docker compose up -d --build
```

The extensions are downloaded from Maven and installed while the image is built, and the documentation search index is built at the same time, so a new container starts without downloading anything. At runtime the container only needs network access to GitHub, to check the recipes for changes (if GitHub is not reachable, the existing index is used).

## Ports

| Port   | Service |
|--------|---------|
| `8856` | Tomcat  |

## MCP Endpoint

`POST /` is the JSON-RPC endpoint — there is no separate path per tool.

```
POST /
```

Example: `http://localhost:8856/`

`GET /` (or any other method) serves an HTML landing page describing the endpoint, its tools, and how to add it to Claude, ChatGPT, and Gemini.

### Tools

| Tool | Arguments | Description |
|------|-----------|-------------|
| `get_lucee_function` | `name` (string) | FLD descriptor for a built-in function |
| `get_lucee_tag` | `name` (string) | TLD descriptor for a tag |
| `search_lucee_docs` | `query` (string), `maxResults` (int, optional) | Lucene full-text search across functions, tags, and recipes |
| `parse_cfml_ast` | `source`, `mode`, `summary`, `maxDepth` | Parse CFML into an AST tree or compact summary |
| `query_cfml_ast` | `source`, `nodeType`, `name`, `line`, `builtInOnly` | Find matching AST nodes in parsed CFML |

The AST tools require Lucee 7.0.0.296+ and MCP Server 1.0.1.0+.

## Configuration

| Variable | Default | Purpose |
|----------|---------|---------|
| `LUCEE_ADMIN_PASSWORD` | `qwerty` | Lucee Administrator password |
| `PORT` | `8080` | HTTP port Tomcat listens on (Cloud Run sets this) |

Settings of the MCP Server extension can also be passed as environment variables, see the [extension README](https://github.com/lucee/extension-mcp-server).

### Build arguments

| Argument | Default | Purpose |
|----------|---------|---------|
| `LUCEE_IMAGE` | `lucee/lucee:7.1.1.17-light` | Lucee base image |
| `MCP_SERVER_VERSION` | `1.0.1.6` | MCP Server extension version |
| `LUCENE_SEARCH_VERSION` | `3.0.0.163` | Lucene Search extension version |
| `ESAPI_VERSION` | `3.0.0.14` | ESAPI extension version |
| `MAVEN_REPOSITORY` | `https://repo1.maven.org/maven2` | Maven repository the extensions are downloaded from |
| `PREBUILD_SEARCH_INDEX` | `true` | Build the documentation search index while building the image |

```bash
docker build --build-arg MCP_SERVER_VERSION=1.0.1.6 -t lucee-mcp .
```

The MCP Server extension does not implement endpoint authentication.

## Example curl

```bash
# List tools (expect 5)
curl -s -X POST http://localhost:8856/ \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/list","id":1}'

# Look up a function
curl -s -X POST http://localhost:8856/ \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","id":2,"params":{"name":"get_lucee_function","arguments":{"name":"arraySort"}}}'

# Search documentation (the index is built into the image)
curl -s -X POST http://localhost:8856/ \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","id":3,"params":{"name":"search_lucee_docs","arguments":{"query":"how to read a file","maxResults":3}}}'
```

## CFConfig

The image ships a single CFConfig file (`lucee-config.json`) with the component mapping and loggers. Rebuild the image (`docker compose up -d --build`) after changing it.

## Extensions

The MCP Server, Lucene Search, and ESAPI extensions (ESAPI provides `encodeForHTML`/`encodeForURL`, used by the landing page) are downloaded from Maven into Lucee's deploy folder during the build. `prepare-image.sh` then starts Lucee once inside the build, which installs them, compiles the templates, and builds the documentation search index, and stops it again. Use the build arguments above to change the versions.

## Server.cfc

`Server.cfc` (copied to `lucee-server/context/context/Server.cfc`) creates the `MCPServer` instance once, in the global `server` scope, when the Lucee server starts — shared across all requests instead of being rebuilt per application/request. `index.cfm` creates it on the first request if it does not exist yet.

## Cursor / Claude MCP client config

```json
{
    "mcpServers": {
        "lucee": {
            "url": "http://localhost:8856/"
        }
    }
}
```

See the [extension README](https://github.com/lucee/extension-mcp-server) for tool details, custom URL mappings, and adding your own tools.
