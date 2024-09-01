private
pollNeverDelivered

	^ self consumer
		  neverDeliveredNoAckAtMost: self readChunkSize
		  waitFor: self waitMilliseconds