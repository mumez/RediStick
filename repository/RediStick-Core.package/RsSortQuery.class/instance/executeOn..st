protected
executeOn: aRedisEndpoint
	| args |
	args := OrderedCollection new.
	by
		ifNotNil: [ args
				add: 'BY';
				add: by ].
	start
		ifNotNil: [ args
				add: 'LIMIT';
				add: start;
				add: count ].
	get
		ifNotNil: [ args
				add: 'GET';
				add: get ].
	mGet
		ifNotNil: [ mGet
				do: [ :ea | 
					args
						add: 'GET';
						add: ea ] ].
	descending ifNotNil: [ args add: 'DESC' ].
	alpha ifNotNil: [ args add: 'ALPHA' ].
	store
		ifNotNil: [ args
				add: 'STORE';
				add: store ].
	^ args isEmpty
		ifTrue: [ aRedisEndpoint inlineCommand: 'SORT' key: key ]
		ifFalse: [ aRedisEndpoint multiBulkCommand: 'SORT' args: {key} , args ]