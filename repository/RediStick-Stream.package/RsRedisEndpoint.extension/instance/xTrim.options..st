*RediStick-Stream
xTrim: key options: trimOptions
	| args |
	args := {
		        'XTRIM'.
		        key } asOrderedCollection.
	trimOptions ifNotNil: [ args addAll: trimOptions asArray ].
	^ self unifiedCommand: args 