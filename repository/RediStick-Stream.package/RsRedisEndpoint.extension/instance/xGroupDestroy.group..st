*RediStick-Stream
xGroupDestroy: key group: group
	| args |
	args := {
		        'XGROUP'.
		        'DESTROY'.
		        key.
		        group } asOrderedCollection.
	^ self unifiedCommand: args