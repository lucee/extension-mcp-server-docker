# Lucee MCP Server — Docker

Minimal Docker image running Lucee 7.1 with the [MCP Server extension](https://github.com/lucee/extension-mcp-server). The MCP JSON-RPC endpoint is mapped to the webroot — there is no separate landing page or test UI.

This image does **not** install the Lucene Search extension. `search_lucee_docs` is still listed as a tool but returns a message that Lucene is required when called.

## Quick Start

```bash
git clone https://github.com/lucee/extension-mcp-server-docker.git
cd extension-mcp-server-docker
docker compose up -d --build
```

Lucee downloads the MCP extension on first startup. The container needs network access to Maven / the Lucee extension provider.

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
| `search_lucee_docs` | `query` (string), `maxResults` (int, optional) | Lucene search — **requires Lucene extension (not installed in this image)** |
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
```

Replace `8856` with `8056` when using the Nginx port.

## CFConfig

The image ships a single CFConfig file that maps `/` to the MCP extension context and installs MCP Server 1.0.1.0-BETA from Maven. Add the Lucene Search extension to `extensions` in `lucee-config.json` if you need `search_lucee_docs` to work.

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
