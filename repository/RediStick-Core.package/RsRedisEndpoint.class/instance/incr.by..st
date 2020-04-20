commands-strings
incr: aKey by: anInteger
	| val |
	val :=  (self
		unifiedCommand:
			{'INCRBY'.
			aKey.
			anInteger}).
	^val ifNotNil: [ :v | v  asNumber]