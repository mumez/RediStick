factory
restoreSubscriber: oldSubscriber
	| oneShotStick subscribed retryMax |
	oldSubscriber destroy.
	subscribed := false.
	retryMax := self maxSubscriberRestorationRetries.
	[ subscribed not and: [ retryMax > 0 ] ] whileTrue: [
		(Delay forSeconds: self restoreSubscriberWaitSeconds) wait.
		oneShotStick := RsRediStick targetUrl: self targetUrl.
		oneShotStick onConnected: [ :stick |
			stick destroy.
			self prepareSubscriber.
			self subscribeChannels.
			self logger info: '-subscribe again-'.
			subscribed := true ].
		oneShotStick connect.
		retryMax := retryMax - 1 ].
	self logger info: '-restoration result-', {subscribed. retryMax} asString.
	self onSubscriberNotRestored ifNotNil: [ self onSubscriberNotRestored value ]