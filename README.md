# Lucee MCP Server — Docker

Minimal Docker image running Lucee 8.0 (light) with the [MCP Server extension](https://github.com/lucee/extension-mcp-server). `GET /` serves a landing page explaining the endpoint and its tools; `POST /` is the MCP JSON-RPC endpoint.

This image installs the Lucene Search extension so `search_lucee_docs` can index and search Lucee documentation (functions, tags, and recipes).

## Quick Start

```bash
git clone https://github.com/lucee/extension-mcp-server-docker.git
cd extension-mcp-server-docker
docker compose up -d --build
```

Lucee downloads the MCP and Lucene extensions on first startup. The container needs network access to Maven / the Lucee extension provider and to GitHub (for recipe indexing on the first search call).

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
| `parse_cfml_ast` | `source` or `path`, `mode`, `summary`, `maxDepth` | Parse CFML into an AST tree or compact summary |
| `query_cfml_ast` | `source` or `path`, `nodeType`, `name`, `line`, `builtInOnly` | Find matching AST nodes in parsed CFML |

The AST tools require Lucee 7.0.0.296+ and MCP Server 1.0.1.0+.

## Configuration

| Variable | Default | Purpose |
|----------|---------|---------|
| `LUCEE_ADMIN_PASSWORD` | `qwerty` | Lucee Administrator password |

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

# Search documentation (first call builds the Lucene index; may take a few seconds)
curl -s -X POST http://localhost:8856/ \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","id":3,"params":{"name":"search_lucee_docs","arguments":{"query":"how to read a file","maxResults":3}}}'
```

## CFConfig

The image ships a single CFConfig file that installs the MCP Server, Lucene Search, and ESAPI extensions from Maven (ESAPI provides `encodeForHTML`/`encodeForURL`, used by the landing page). CFConfig extensions are applied on a fresh server install — recreate the container (`docker compose down && docker compose up -d --build`) after changing `lucee-config.json`.

## Server.cfc

`Server.cfc` (copied to `lucee-server/context/context/Server.cfc`) creates the `MCPServer` instance once, in the global `server` scope, when the Lucee server starts — shared across all requests instead of being rebuilt per application/request.

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
