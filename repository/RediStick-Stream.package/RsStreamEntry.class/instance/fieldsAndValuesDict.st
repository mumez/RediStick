accessing
fieldsAndValuesDict
	^ self fieldsAndValues inject: Dictionary new into: [ :sum :each  | 
		sum at: each key put: each value; yourself
	]