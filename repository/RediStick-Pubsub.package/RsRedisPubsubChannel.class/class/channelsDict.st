accessing
channelsDict
	^ channelsDict
		ifNil: [ self initChannelsDict.
			channelsDict ]