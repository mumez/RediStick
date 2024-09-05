initialization
initFromOrderedCollection: rawValues
	rawValues ifNil: [ ^ self ].
	rawValues pairsDo: [ :key :value | self initVariableAt: key value: value ]