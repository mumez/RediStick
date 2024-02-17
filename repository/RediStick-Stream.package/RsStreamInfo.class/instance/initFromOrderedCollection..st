initialization
initFromOrderedCollection: rawValues
	rawValues pairsDo: [ :key :value | self initVariableAt: key value: value ]