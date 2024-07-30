private
basicPoll

	^ [
	  self currentId
		  ifNil: [
			  self stream
				  comingAtMost: self readChunkSize
				  waitFor: self waitMilliseconds ]
		  ifNotNil: [
			  self stream
				  nextAtMost: self readChunkSize
				  after: self currentId
				  waitFor: self waitMilliseconds ] ]
		  on: Error
		  do: [ :ex |
			  (Delay forMilliseconds: 500) wait.
			  self onPollFailed value: ex.
			  #(  ) ]