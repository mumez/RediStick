private
pollNeverDelivered
	^ self consumer
		  neverDeliveredAtMost: self readChunkSize
		  waitFor: self waitMilliseconds