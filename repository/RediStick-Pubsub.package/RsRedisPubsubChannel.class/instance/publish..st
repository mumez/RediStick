publishing
publish: message
	self publisherRedis publish: self channelName message: (STONJSON toString: message)