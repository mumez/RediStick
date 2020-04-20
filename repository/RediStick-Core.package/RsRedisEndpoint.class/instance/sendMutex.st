accessing
sendMutex
	^sendMutex ifNil: [ sendMutex := Mutex new ]