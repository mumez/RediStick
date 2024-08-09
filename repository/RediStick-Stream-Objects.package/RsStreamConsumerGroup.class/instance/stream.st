accessing
stream
	^ stream ifNil: [ stream := self createStream ]