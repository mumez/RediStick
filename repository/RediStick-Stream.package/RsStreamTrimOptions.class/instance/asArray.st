converting
asArray
	| opts |
	self strategy ifNil: [ ^#() ].
	opts := { self strategy } asOrderedCollection.
	self operator ifNotNil: [ :op | opts add: op ].
	opts add: self threshold.
	self limit ifNotNil: [ :li | opts add: li ].
	^ opts asArray