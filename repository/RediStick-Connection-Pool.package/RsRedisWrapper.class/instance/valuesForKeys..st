actions
valuesForKeys: keys
	^(self endpoint mGet: keys) ifNil: [ #() ]