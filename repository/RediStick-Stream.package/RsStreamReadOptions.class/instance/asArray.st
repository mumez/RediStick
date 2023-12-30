converting
asArray
	| opts |
	opts := {} asOrderedCollection.
	self count ifNotNil: [ :op | opts addAll: {'COUNT'. op} ].
	self blocking ifNotNil: [ :op | opts addAll: {'BLOCK'. op} ].
	^ opts asArray