udp = require "dgram"
settings = require "../settings"

sendUDP = (socket, ip, port, data, cb) ->
	if not data?.length > 0 then throw new Error "Packet can't be sent: "+data
	if not socket?
		socket = udp.createSocket "udp4"
		clean1 = (err, data, info) ->
			clean1 = ->
			clearTimeout timeoutSend
			socket.close()
			cb err, data, info
		timeoutSend = setTimeout ->
			clean1 new Error "Time exceeded"
		, 3000
		socket.on "error", (err) -> clean1 err
		socket.on "close", -> clean1 new Error "UDP send socket closed"
		socket.on "message", (data, info) ->
			clean1 null, data, info
		socket.send data, 0, data.length, port, ip, (err) -> if err?
			clean1 err
	else
		clean2 = (err) ->
			clean2 = ->
			clearTimeout timeoutSend
			cb err
		timeoutSend = setTimeout ->
			clean2 new Error "Send time exceeded"
		, 3000
		socket.send data, 0, data.length, port, ip, (err) -> clean2 err

forwardUDP = (data, limiterUDP, cb) ->
	nbErrors = 0
	clean = (err, data, info) ->
		clean = ->
		clearTimeout timeoutDown
		cb err, data, info
	timeoutDown = setTimeout ->
		clean new Error "Time exceeded ("+nbErrors+" errors)"
	, 3500

	limiterUDP.submit sendUDP, null, settings.forwardDNS, settings.forwardDNSPort, data, (err, resData, resInfo) ->
		if err?
			nbErrors++
		clean err, resData, resInfo

module.exports = {sendUDP, forwardUDP}
