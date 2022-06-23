private
resetSubscriptions

	[ RsRedisSubscriptionManager reset ]
		on: Error
		do: [ :ex | RsRedisSubscriptionManager logger error: ex ]