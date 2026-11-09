<cfscript>
setting showdebugoutput=false;

if (cgi.request_method == "POST") {
	// normally created by Server.cfc on server start, created here as a fallback
	if (!structKeyExists(server, "mcpServer")) {
		lock name="lucee-mcp-server-init" type="exclusive" timeout=60 {
			if (!structKeyExists(server, "mcpServer")) {
				server.mcpServer = new org.lucee.extension.mcp.MCPServer();
			}
		}
	}
	server.mcpServer.handle();
	abort;
}

endpointUrl = "https://" & cgi.http_host & "/";

tools = [
	{ name: "get_lucee_function", args: "name",                                    desc: "FLD descriptor for a built-in Lucee function." },
	{ name: "get_lucee_tag",      args: "name",                                    desc: "TLD descriptor for a Lucee tag." },
	{ name: "search_lucee_docs",  args: "query, maxResults",                       desc: "Full-text search across functions, tags, and recipes." },
	{ name: "parse_cfml_ast",     args: "source, mode, summary, maxDepth",         desc: "Parse CFML source into an AST tree or compact summary." },
	{ name: "query_cfml_ast",     args: "source, nodeType, name, line",            desc: "Find matching nodes in already-parsed CFML." }
];
</cfscript>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Lucee MCP Server</title>
	<link rel="icon" type="image/png" href="/res/favicon.png">
	<script>try{var t=localStorage.getItem("lucee-theme");if(t==="light"||t==="dark")document.documentElement.setAttribute("data-theme",t)}catch(e){}</script>
	<link rel="stylesheet" href="/res/lucee-header/theme.css" data-lucee-theme-css>
	<link rel="stylesheet" href="/res/lucee-header/header.css" data-lucee-header-css>
	<script src="/res/lucee-header/header.js" defer></script>
	<link rel="stylesheet" href="/res/mcp.css?v=2">
</head>
<body>
<cfoutput>

<!--- ── Header ── --->
<lucee-header home="https://lucee.org/" current="ai">
	<a href="https://lucee.org/" aria-label="Lucee home">Lucee</a><a href="https://download.lucee.org/">Download</a><a href="https://docs.lucee.org/">Docs</a><a href="https://lucee.org/extensions">Extensions</a><a href="https://lucee.org/community">Community</a><a href="https://lucee.org/ai">AI</a><a href="https://lucee.org/support">Support</a>
</lucee-header>

<div class="container">

<!--- ── Page title ── --->
<div class="page-title">
	<h1>Lucee MCP Server</h1>
</div>

<!--- ── What is MCP ── --->
<section>
	<h2 class="section-title">What is MCP?</h2>
	<p class="section-intro">
		The <strong>Model Context Protocol</strong> (MCP) is an open standard that lets AI assistants call tools over a
		simple JSON-RPC interface instead of guessing from training data. This server exposes Lucee's own function and
		tag reference, full-text doc search, and CFML AST parsing as MCP tools — so an assistant can look up exact
		signatures, search recipes, and inspect real CFML source before it answers.
	</p>
</section>

<!--- ── Endpoint ── --->
<section>
	<h2 class="section-title">Endpoint</h2>
	<div class="endpoint-card">
		<div class="endpoint-card-header">
			<div class="endpoint-card-icon">
				<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M12 1v4M12 19v4M4.22 4.22l2.83 2.83M16.95 16.95l2.83 2.83M1 12h4M19 12h4M4.22 19.78l2.83-2.83M16.95 7.05l2.83-2.83"/></svg>
			</div>
			<div>
				<h3>Lucee MCP Server</h3>
				<div class="endpoint-card-name">lucee-docs</div>
			</div>
		</div>
		<div class="endpoint-card-body">
			<p>Single JSON-RPC 2.0 endpoint — no separate path per tool. Point your MCP client's server URL at the address below.</p>
			<div class="endpoint-card-meta">
				<span class="endpoint-meta-chip method-post">POST only</span>
				<span class="endpoint-meta-chip">JSON-RPC 2.0</span>
				<span class="endpoint-meta-chip">MCP protocol 2024-11-05</span>
				<span class="endpoint-meta-chip">#arrayLen(tools)# tools available</span>
			</div>
		</div>
		<div class="endpoint-card-footer">
			<span class="endpoint-url">#encodeForHTML(endpointUrl)#</span>
		</div>
	</div>
</section>

<!--- ── Available Tools ── --->
<section>
	<h2 class="section-title">Available Tools</h2>
	<table class="tools-table">
		<thead>
			<tr><th>Tool</th><th>Arguments</th><th>Description</th></tr>
		</thead>
		<tbody>
			<cfloop array="#tools#" item="tool">
			<tr>
				<td><code>#encodeForHTML(tool.name)#</code></td>
				<td class="tool-desc">#encodeForHTML(tool.args)#</td>
				<td class="tool-desc">#encodeForHTML(tool.desc)#</td>
			</tr>
			</cfloop>
		</tbody>
	</table>
</section>

<hr class="section-divider">

<!--- ── Using MCP with AI Assistants ── --->
<section>
	<h2 class="section-title">Using MCP with Your AI Assistant</h2>
	<p class="section-intro">Add the endpoint above as an MCP server in your client of choice:</p>
	<div class="assistant-grid">
		<article class="assistant-card">
			<h3>Claude</h3>
			<p>
				Claude Desktop and Claude Code support MCP natively. Add an entry to your MCP config
				(<code>.mcp.json</code> or Claude Desktop's settings) with this server's URL, then restart the client.
			</p>
		</article>
		<article class="assistant-card">
			<h3>ChatGPT</h3>
			<p>
				Add the endpoint as a custom connector under Settings → Connectors (Developer Mode), so ChatGPT can
				call the Lucee tools during a conversation.
			</p>
		</article>
		<article class="assistant-card">
			<h3>Gemini</h3>
			<p>
				Register the endpoint as an MCP server in the Gemini CLI's settings (or your Gemini client's MCP
				configuration) to give Gemini the same tool access.
			</p>
		</article>
	</div>
</section>

</div><!--- .container --->

<!--- ── Footer ── --->
<footer class="site-footer">
	<span>&copy; Lucee Association Switzerland</span>
	<span>
		<a href="https://github.com/lucee" target="_blank">GitHub</a> &middot;
		<a href="https://dev.lucee.org"    target="_blank">Forum</a> &middot;
		<a href="https://docs.lucee.org"   target="_blank">Docs</a> &middot;
		<a href="https://hub.docker.com/r/lucee/lucee" target="_blank">Docker Hub</a> &middot;
		<a href="https://opencollective.com/lucee" target="_blank">Donate</a>
	</span>
</footer>

</cfoutput>
</body>
</html>
