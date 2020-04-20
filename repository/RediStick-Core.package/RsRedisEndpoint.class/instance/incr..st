commands-strings
incr: aKey
	| val |
	val := (self
		unifiedCommand:
			{'INCR'.
			aKey}).
	^val ifNotNil: [ :v | v  asNumber]