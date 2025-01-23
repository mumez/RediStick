commands-lists
lPosBackward: aKey value: value maxlen: maxlen
	^ self
		  lPos: aKey
		  value: value
		  rank: -1
		  count: nil
		  maxlen: maxlen