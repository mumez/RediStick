actions
keys: pattern
	| keys |
	keys := self endpoint keys: pattern.
	keys ifNil: [ ^ OrderedCollection new ].
	^ keys