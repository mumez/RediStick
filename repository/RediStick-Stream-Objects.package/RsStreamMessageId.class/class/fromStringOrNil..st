instance creation
fromStringOrNil: aStringOrNil
	aStringOrNil ifNil: [ ^nil ].
	^ self fromString: aStringOrNil 