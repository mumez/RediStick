*RediStick-Stream
xAck: key group: group ids: ids
	| args |
	args := {
		        'XACK'.
		        key.
		        group } asOrderedCollection.
	args addAll: ids.
	^ self unifiedCommand: args