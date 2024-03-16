*RediStick-Stream
xGroupDelConsumer: key group: group consumer: consumer
	| args |
	args := {
		        'XGROUP'.
		        'DELCONSUMER'.
		        key.
		        group.
		        consumer } asOrderedCollection.
	^ self unifiedCommand: args