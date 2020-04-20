commands-strings
mGet: keys
	keys ifEmpty: [ ^#() ].
	^ self unifiedCommand: {'MGET'} , keys