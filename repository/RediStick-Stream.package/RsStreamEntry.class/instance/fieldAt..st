accessing
fieldAt: key
	^ self fieldsAndValuesDict at: key ifAbsent: [  ]