initialization
initFromOrderedCollection: rawValues
	rawValues size = 3 ifTrue: [
		self id: (rawValues at: 1).
		self deliveredTimestamp: (rawValues at: 2).
		^ self deliveredCount: (rawValues at: 3) ].
	
	self id: (rawValues at: 1).
	self owner: (rawValues at: 2).
	self deliveredTimestamp: (rawValues at: 3).
	self deliveredCount: (rawValues at: 4)