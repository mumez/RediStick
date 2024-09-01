*RediStick-Stream
xAdd: key createNotExists: createNotExists trimOptions: trimOptions id: id fieldsAndValues: fieldAndValues
	| args |
	args := {
		        'XADD'.
		        key } asOrderedCollection.
	createNotExists ifFalse: [ args add: 'NOMKSTREAM' ].
	trimOptions ifNotNil: [ args addAll: trimOptions asArray ].
	id ifNil: [ args add: '*' ] ifNotNil: [ args add: id asString ].
	args addAll: (fieldAndValues gather: [ :each | {each key. each value}]).
	^ self unifiedCommand: args