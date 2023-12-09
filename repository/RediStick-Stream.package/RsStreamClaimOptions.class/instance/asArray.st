converting
asArray
	| opts |
	opts := {} asOrderedCollection.
	self idleMilliseconds ifNotNil: [ :op | opts addAll: {'IDLE'. op} ].
	self idleTimeAt  ifNotNil: [ :op | opts addAll: {'TIME'. op} ].
	self retryCount ifNotNil: [ :op | opts addAll: {'RETRYCOUNT'. op} ].
	self forceCreate ifTrue: [ opts add: 'FORCE' ].
	self idsOnly ifTrue: [ opts add: 'JUSTID' ].
	self lastId ifNotNil: [ :op | opts addAll: {'LASTID'. op} ].
	^ opts asArray