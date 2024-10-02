accessing
currentId
	currentId ifNil: [ ^ self fallbackId ].
	^ currentId 