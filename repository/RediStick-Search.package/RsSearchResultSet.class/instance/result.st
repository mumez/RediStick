accessing
result
	self results ifEmpty: [ ^ nil ].
	^ self results at: 1