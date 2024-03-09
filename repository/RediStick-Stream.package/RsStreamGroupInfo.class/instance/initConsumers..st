initialization
initConsumers: value
	| cons |
	cons := value isInteger
		        ifTrue: [ value ]
		        ifFalse: [
			        value collect: [ :each |
				        RsStreamConsumerEntry fromOrderedCollection: each ] ].
	self consumers: cons