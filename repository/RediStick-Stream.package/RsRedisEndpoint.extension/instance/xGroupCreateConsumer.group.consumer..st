*RediStick-Stream
xGroupCreateConsumer: key group: group consumer: consumer
	| args |
	args := {
		        'XGROUP'.
		        'CREATECONSUMER'.
		        key.
		        group.
		        consumer } asOrderedCollection.
	^ self unifiedCommand: args