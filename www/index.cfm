<cfscript>
setting showdebugoutput=false;

if (cgi.request_method == "POST") {
	server.mcpServer.handle();
	abort;
}

endpointUrl = "https://" & cgi.http_host & "/";

tools = [
	{ name: "get_lucee_function", args: "name",                                    desc: "FLD descriptor for a built-in Lucee function." },
	{ name: "get_lucee_tag",      args: "name",                                    desc: "TLD descriptor for a Lucee tag." },
	{ name: "search_lucee_docs",  args: "query, maxResults",                       desc: "Full-text search across functions, tags, and recipes." },
	{ name: "parse_cfml_ast",     args: "source or path, mode, summary, maxDepth", desc: "Parse CFML source into an AST tree or compact summary." },
	{ name: "query_cfml_ast",     args: "source or path, nodeType, name, line",    desc: "Find matching nodes in already-parsed CFML." }
];
</cfscript>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Lucee MCP Server</title>
	<link rel="icon" type="image/png" href="/res/favicon.png">
	<link rel="stylesheet" href="/res/mcp.css?v=1">
</head>
<body>
<cfoutput>

<!--- ── Header ── --->
<header class="site-header">
	<a href="/" class="logo">
		<img src="/res/lucee-logo.svg" alt="Lucee" height="36">
		<span class="logo-subtitle">MCP</span>
	</a>
	<nav>
		<a href="https://docs.lucee.org"     target="_blank">Docs</a>
		<a href="https://dev.lucee.org"      target="_blank">Forum</a>
		<a href="https://github.com/lucee"   target="_blank">GitHub</a>
		<a href="https://hub.docker.com/r/lucee/lucee" target="_blank">Docker Hub</a>
		<a href="https://buymeacoffee.com/luceeorg" target="_blank" class="bmc-link">
			<img src="/res/byme2.png" class="bmc-icon" alt="Buy me a coffee">
			<img src="/res/byme.png"  class="bmc-full" alt="Buy me a coffee">
		</a>
		<a href="https://opencollective.com/lucee" target="_blank" class="nav-highlight">
			<svg width="13" height="13" viewBox="0 0 24 24" fill="currentColor" stroke="none"><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg>
			Donate
		</a>
		<a href="https://skill.lucee.io/" target="_blank" class="nav-highlight">
			<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
			Skills
		</a>
		<a href="https://download.lucee.org/" target="_blank" class="nav-highlight">
			<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3v12m0 0l-4-4m4 4l4-4"/><path d="M4 17v2a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-2"/></svg>
			Downloads
		</a>
	</nav>
</header>

<div class="container">

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
		<a href="https://hub.docker.com/r/lucee/lucee" target="_blank">Docker Hub</a>
	</span>
</footer>

</cfoutput>
</body>
</html>
