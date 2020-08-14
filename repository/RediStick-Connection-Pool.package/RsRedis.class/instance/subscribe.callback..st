pubsub
subscribe: channelArray callback: aBlock 
	^self endpoint subscribe: (channelArray collect: #asString) callback: aBlock 