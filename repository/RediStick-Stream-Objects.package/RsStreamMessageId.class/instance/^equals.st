comparing
= other
	self class = other class ifFalse: [ ^ false ].
	self mainId = other mainId ifFalse: [ ^ false ].
	self subId = other subId ifFalse: [ ^ false ].
	^ true