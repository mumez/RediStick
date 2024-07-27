actions
poll
	| received |
	received := self currentId
		            ifNil: [
			            self stream
				            comingAtMost: self settings iterationReadChunkSize
				            waitFor: self settings waitMilliseconds ]
		            ifNotNil: [
			            self stream
				            nextAtMost: self settings iterationReadChunkSize
				            after: self currentId
				            waitFor: self settings waitMilliseconds ].

	received do: [ :each |
		self onReceived value: each.
		self currentId: each id ]