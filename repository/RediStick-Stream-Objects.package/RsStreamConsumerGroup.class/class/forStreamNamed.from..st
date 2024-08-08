instance creation
forStreamNamed: streamName from: fromId
	^ (self forStreamNamed: streamName)
		  fromId: fromId;
		  yourself