private
basicPoll
	^ self consumer
		  neverDeliveredAtMost: self readChunkSize
		  waitFor: self waitMilliseconds