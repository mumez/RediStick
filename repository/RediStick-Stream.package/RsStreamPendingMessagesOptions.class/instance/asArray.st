converting
asArray
	| opts |
	opts := {} asOrderedCollection.
	self minIdleMilliseconds ifNotNil: [ :op | opts addAll: {'IDLE'. op} ].
	opts add: self start.
	opts add: self end.
	opts add: self count.
	self consumer ifNotNil: [ :con | opts add: con ].
	^ opts asArray