converting
asArray
	| opts |
	opts := super asArray.
	self noAck ifNotNil: [ :op | opts addAll: {'NOACK'. op} ].
	^ opts asArray