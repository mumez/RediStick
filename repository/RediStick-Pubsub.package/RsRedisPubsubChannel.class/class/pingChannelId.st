accessing
pingChannelId
	pingChannelId ifNil: [ self initPingChannelId ].
	^pingChannelId 