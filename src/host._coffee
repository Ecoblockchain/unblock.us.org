crypto = require "crypto"
url = require "url"
asyncReplace = require "async-replace"
settings = require "../settings"
Bottleneck = require "bottleneck"

getHash = (redisClient, host, clientIP, _) ->
	savedHashKey = "hash-"+clientIP+"-"+host
	hash = redisClient.get savedHashKey, _

	# That IP hasn't asked for that domain before
	if not hash?
		hash = (crypto.pseudoRandomBytes 16, _).toString "hex"
		keys = ["hostTunneling-"+hash, "xforwardedfor-"+hash, savedHashKey]
		values = [host, clientIP, hash]
		keys.forEach_ _, -1, (_, k, i) ->
			redisClient.set [k, values[i]], _
			redisClient.expire [k, settings.hostTunnelingCaching], _
	hash

redirectToHash = (res, hash, path) ->
	redirect = "https://"+hash+"."+settings.hostTunnelingDomain+path
	res.writeHead 302, {Location:redirect}
	res.end """<html><body>The unblock.us.org project<br /><br />Unblocked at <a href="#{redirect}">#{redirect}</a></body></html>"""

contentTypes = {
	"application/javascript", "application/xhtml+xml", "application/xml", "image/svg+xml", "text/css", "text/html", "text/javascript"
}
isAltered = (ct) -> contentTypes[ct]?

# This will probably need a lot of tweaking
# TODO: Document this monster
rDomains = new RegExp "(.|^)(?:https://)?(?:(?:[a-zA-Z0-9\-]+[.]{1})*?)?(?:"+("(?:"+a.replace(/[.]/g, "[.]")+")" for a of settings.hijacked).join("|")+")", "g"
rLookbehind = new RegExp "^[^a-zA-Z0-9\-.]?$"
redirectAllURLs = (str, redisClient, clientIP, hashCache, _) ->
	limiter = new Bottleneck 1
	asyncReplace str, rDomains, ((found, lookbehind, position, text, _) ->
		if not rLookbehind.test(lookbehind) then return found # False positive. Javascript doesn't support real lookbehinds
		if lookbehind.length > 0 then found = found[1..]

		parsed = url.parse found
		parsed.path = ""
		parsed.pathname = ""
		if not parsed.host? or not parsed.hostname?
			parsed.hostname = parsed.href
		parsed.host = null # Force the url module to use hostname+port
		if parsed.protocol? then parsed.protocol = "https"
		if hashCache[parsed.hostname]? and false
			parsed.hostname = hashCache[parsed.hostname]+"."+settings.hostTunnelingDomain
		else
			hash = limiter.submit getHash, redisClient, parsed.hostname, clientIP, _
			hashCache[parsed.hostname] = hash
			parsed.hostname = hash+"."+settings.hostTunnelingDomain
		formatted = url.format parsed
		if formatted[0..1] == "//" then lookbehind+formatted[2..] else lookbehind+formatted
	), _

module.exports = {getHash, redirectToHash, isAltered, redirectAllURLs}
