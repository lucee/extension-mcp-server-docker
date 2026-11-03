#!/bin/sh
# Runs once at image build time: starts Lucee so it installs the extensions
# from the deploy folder, calls the MCP endpoint so the templates are compiled,
# optionally builds the documentation search index, then stops Lucee again.
set -e

URL="http://127.0.0.1:8888/"
OUT=/tmp/prepare-image.out

/usr/local/tomcat/bin/catalina.sh start

stop() {
	/usr/local/tomcat/bin/catalina.sh stop 30 -force > /dev/null 2>&1 || true
	rm -f "$OUT"
}
trap stop EXIT

fail() {
	echo "$1" >&2
	[ -f "$OUT" ] && cat "$OUT" >&2
	tail -n 50 /usr/local/tomcat/logs/catalina.out >&2 || true
	exit 1
}

post() {
	wget -q -O "$OUT" --timeout=600 --tries=1 \
		--header="Content-Type: application/json" \
		--post-data="$1" "$URL"
}

i=0
until post '{"jsonrpc":"2.0","method":"tools/list","id":1}' 2> /dev/null && grep -q "search_lucee_docs" "$OUT"; do
	i=$((i + 1))
	[ "$i" -ge 60 ] && fail "MCP endpoint did not become available"
	sleep 2
done

for ext in /opt/lucee/server/lucee-server/deploy/*.lex; do
	[ -e "$ext" ] && fail "extension was not installed: $ext"
done

# The extensions declared in lucee-config.json (installed at their latest version
# by this first start) must provide their tags and functions: look one up for each.
lookup() {
	post "{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"id\":3,\"params\":{\"name\":\"$1\",\"arguments\":{\"name\":\"$2\"}}}" \
		|| fail "$1 $2 request failed"
	grep -q '"isError":true' "$OUT" && fail "$1 $2 returned an error"
	grep -q " not found" "$OUT" && fail "extension not installed: $1 $2 not found"
	grep -qi "$2" "$OUT" || fail "extension not installed: $1 $2 returned no data"
}
lookup get_lucee_tag mail
lookup get_lucee_tag ftp
lookup get_lucee_tag pdf
lookup get_lucee_function s3Exists
lookup get_lucee_function imageNew
lookup get_lucee_function redisCommand

wget -q -O /dev/null --timeout=120 "$URL" || fail "landing page failed"

if [ "$PREBUILD_SEARCH_INDEX" = "true" ]; then
	post '{"jsonrpc":"2.0","method":"tools/call","id":2,"params":{"name":"search_lucee_docs","arguments":{"query":"arraySort","maxResults":1}}}' \
		|| fail "search request failed"
	grep -q '"isError":true' "$OUT" && fail "search returned an error"
	grep -q "arraySort" "$OUT" || fail "search index was not built"
	echo "search index built"
fi

stop
trap - EXIT

# Lucene keeps empty write.lock files; remove them so the first index update
# in a container does not trip over lock files copied from the image layer.
find /opt/lucee/server/lucee-server/context -name write.lock -type f -delete

echo "image prepared"
