commands-strings
decr: aKey by: anInteger
	| val |
	val :=  (self
		unifiedCommand:
			{'DECRBY'.
			aKey.
			anInteger}).
	^val ifNotNil: [:v | v asNumber]