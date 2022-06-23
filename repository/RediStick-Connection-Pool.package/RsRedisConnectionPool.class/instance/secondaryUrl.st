accessing
secondaryUrl
	^secondaryUrl ifNil: [secondaryUrl := self class secondaryUrl]