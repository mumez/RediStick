accessing
secondaryUrl
	^secondaryUrl ifNil: [ secondaryUrl := 'sync://localhost:6380' ]