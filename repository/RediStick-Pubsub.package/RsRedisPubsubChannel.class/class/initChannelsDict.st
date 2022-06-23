class initialization
initChannelsDict
	channelsDict := IdentityDictionary new.
	self allSubclassesDo: [ :each | channelsDict at: each channelName asSymbol put: each new ]