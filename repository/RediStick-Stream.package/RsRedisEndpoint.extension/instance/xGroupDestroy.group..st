*RediStick-Stream
xGroupDestroy: key group: group
	| args |
	args := {
		        'XGROUP'.
		        'DELCONSUMER'.
		        key.
		        group } asOrderedCollection.
	^ self unifiedCommand: args