printing
printOn: aStream
	aStream nextPutAll: self mainId asString.
	subId ifNil: [ ^ self ].
	aStream nextPut: $-.
	aStream nextPutAll: self subId asString.