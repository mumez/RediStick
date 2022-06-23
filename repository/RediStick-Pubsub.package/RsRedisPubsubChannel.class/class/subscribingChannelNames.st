accessing
subscribingChannelNames
	^ (self channelsDict values select: [ :each | 
		   each shouldBeSubscribed ]) collect: #channelName