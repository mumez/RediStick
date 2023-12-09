*RediStick-Stream
xAutoClaim: key group: group consumer: consumer minIdleTime: minIdleTime start: start count: count idsOnly: idsOnly
	| args |
	args := {
		        'XAUTOCLAIM'.
		        key.
		        group.
		        consumer.
		        minIdleTime.
		        start } asOrderedCollection.
	count ifNotNil: [
		args addAll: {
				'COUNT'.
				count } ].
	idsOnly ifTrue: [ args add: 'JUSTID' ].
	^ self unifiedCommand: args