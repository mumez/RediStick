comparing
< other
	self mainId = other mainId ifTrue: [ ^ self subId < other subId ].
	^ self mainId < other mainId