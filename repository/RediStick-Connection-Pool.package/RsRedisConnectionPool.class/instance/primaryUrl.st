accessing
primaryUrl
	^primaryUrl ifNil: [primaryUrl := self class primaryUrl]