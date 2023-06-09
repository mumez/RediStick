actions
params: nameAndValuesDict
	| nameAndValues |
	nameAndValues := nameAndValuesDict associations gather: [ :each | {each key. each value} ].
	self options
		addAll: {
				'PARAMS'.
				nameAndValues size asString };
		addAll: nameAndValues