private
resetSubscriptions
	[ 
	RsRedisSubscriptionManager initialize.
	RsRedisSubscriptionManager subscribeAllOnStartUp ]
		on: Error
		do: [ :ex | RsRedisSubscriptionManager logger error: ex ]