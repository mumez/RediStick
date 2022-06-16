private
flattenedKeysAndValuesFrom: aDictionary
	^ aDictionary associations gather: [ :each | {each key. each value} ]