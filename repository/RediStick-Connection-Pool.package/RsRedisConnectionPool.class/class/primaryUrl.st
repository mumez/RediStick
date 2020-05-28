accessing
primaryUrl
	^primaryUrl ifNil: [ primaryUrl := 'sync://localhost:6379' ]