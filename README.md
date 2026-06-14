# Lucee MCP Server — Docker

Minimal Docker image running Lucee 7.1 with the [MCP Server extension](https://github.com/lucee/extension-mcp-server). The MCP JSON-RPC endpoint is mapped to the webroot — there is no separate landing page or test UI.

This image installs the Lucene Search extension so `search_lucee_docs` can index and search Lucee documentation (functions, tags, and recipes).

## Quick Start

```bash
git clone https://github.com/lucee/extension-mcp-server-docker.git
cd extension-mcp-server-docker
docker compose up -d --build
```

Lucee downloads the MCP and Lucene extensions on first startup. The container needs network access to Maven / the Lucee extension provider and to GitHub (for recipe indexing on the first search call).

## Ports

| Port   | Service           |
|--------|-------------------|
| `8056` | Nginx (main HTTP) |
| `8856` | Tomcat (direct)   |

Use Tomcat (`8856`) if Nginx is not responding in your environment.

## MCP Endpoint

CFConfig maps the MCP extension to the webroot. **Use `POST /` only** — this image does not expose a separate MCP path.

```
POST /
```

Example: `http://localhost:8856/`

`GET /` returns a JSON-RPC error (`only POST is supported`).

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

Replace `8856` with `8056` when using the Nginx port.

## CFConfig

The image ships a single CFConfig file that maps `/` to the MCP extension context and installs MCP Server and Lucene Search from Maven. CFConfig extensions are applied on a fresh server install — recreate the container (`docker compose down && docker compose up -d --build`) after changing `lucee-config.json`.

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
