actions
valuesAtKeys: pattern
	| keys |
	keys := self keys: pattern.
	keys ifNil: [ ^ #() ].
	^ (self endpoint mGet: keys) ifNil: [ #() ]