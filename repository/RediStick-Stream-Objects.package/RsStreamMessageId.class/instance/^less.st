comparing
< other
	self mainId = other mainId ifTrue: [ ^ self compareSubId: other ].
	^ self mainId < other mainId