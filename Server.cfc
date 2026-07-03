component {

	remote function onServerStart( boolean reload = false ) {
		if ( !structKeyExists( server, "mcpServer" ) ) {
			server.mcpServer = new org.lucee.extension.mcp.MCPServer();
		}
	}

}
