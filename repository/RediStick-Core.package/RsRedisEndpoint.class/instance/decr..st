commands-strings
decr: aKey
	| val |
	val := (self
		unifiedCommand:
			{'DECR'.
			aKey}).
	^val ifNotNil: [:v | v asNumber]