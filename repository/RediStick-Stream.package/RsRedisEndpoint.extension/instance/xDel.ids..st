*RediStick-Stream
xDel: key ids: ids
	| args |
	args := {
		        'XDEL'.
		        key } asOrderedCollection.
	args addAll: (ids collect: [ :each | each asString ]).
	^ self unifiedCommand: args