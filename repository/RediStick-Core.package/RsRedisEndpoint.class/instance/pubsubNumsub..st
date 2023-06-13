commands-pubsub
pubsubNumsub: channelsCollection
	^self unifiedCommand: {'PUBSUB'. 'NUMSUB'} , channelsCollection