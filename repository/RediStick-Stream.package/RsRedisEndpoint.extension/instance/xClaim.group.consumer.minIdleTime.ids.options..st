*RediStick-Stream
xClaim: key group: group consumer: consumer minIdleTime: minIdleTime ids: ids options: claimOptions
	| args |
	args := {
		        'XCLAIM'.
		        key.
		        group.
		        consumer.
		        minIdleTime } asOrderedCollection.
	args addAll: ids.
	claimOptions ifNotNil: [ args addAll: claimOptions asArray ].
	^ self unifiedCommand: args