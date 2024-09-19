initialization
initGroupName: aStreamConsumerGroupName streamName: aStreamName
	self initGroup: (self groupClass named: aStreamConsumerGroupName streamNamed: aStreamName)