commands-pubsub
pubsubNumsub: channels
	^self unifiedCommand: {'PUBSUB'. 'NUMSUB'} , channels