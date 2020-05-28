actions
valuesInListAt: key
	| len |
	len := self endpoint lLen: key.
	^ self endpoint lRange: key start: 0 end: (len - 1)