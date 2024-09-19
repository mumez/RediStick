*RediStick-Stream
xAdd: key createNotExists: createNotExists trimOptions: trimOptions id: id fieldsAndValues: fieldAndValues
	| args fieldAndVals |
	args := {
		        'XADD'.
		        key } asOrderedCollection.
	createNotExists ifFalse: [ args add: 'NOMKSTREAM' ].
	trimOptions ifNotNil: [ args addAll: trimOptions asArray ].
	id ifNil: [ args add: '*' ] ifNotNil: [ args add: id asString ].
	fieldAndVals := fieldAndValues isDictionary
		                ifTrue: [ fieldAndValues associations ]
		                ifFalse: [ fieldAndValues ].
	args addAll: (fieldAndVals gather: [ :each |{each key. each value}]).
	^ self unifiedCommand: args