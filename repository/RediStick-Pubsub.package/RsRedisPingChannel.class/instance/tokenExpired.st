private
tokenExpired
	sentToken ifNil: [ ^false ].
	^ (self secondsFromUnixEpoch - sentToken) > (RsRedisSubscriptionManager default intervalSeconds * 1.1) ceiling