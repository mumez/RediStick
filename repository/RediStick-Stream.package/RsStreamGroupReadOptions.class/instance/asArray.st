converting
asArray
	| opts |
	opts := super asArray.
	self noAck ifNotNil: [ :op | opts := opts , {'NOACK'} ].
	^ opts