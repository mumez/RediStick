*RediStick-Stream
xGroupReadOptions: options group: group consumer: consumer keys: keys ids: ids
	| args vals dict |
	args := {
		        'XREADGROUP'.
		        'GROUP'.
		        group.
		        consumer } asOrderedCollection.
	args addAll: options asArray.
	args add: 'STREAMS'.
	args addAll: keys.
	args addAll: ids.
	vals := self unifiedCommand: args.
	dict := Dictionary new.
	vals ifNil: [ ^ dict ].
	vals do: [ :eachPair |
		dict
			at: eachPair first
			put: (self createStreamEntryFrom: eachPair last) ].
	keys do: [ :each | dict at: each ifAbsentPut: [ #(  ) ] ].
	^ dict