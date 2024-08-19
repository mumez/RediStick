private
basicPoll

	^ self currentId
		  ifNil: [
			  self stream
				  comingAtMost: self readChunkSize
				  waitFor: self waitMilliseconds ]
		  ifNotNil: [
			  self stream
				  nextAtMost: self readChunkSize
				  after: self currentId asStreamMessageId
				  waitFor: self waitMilliseconds ]