tests
testDecr
	stick endpoint set: 'keyA' value: 10.
	self assert: (stick endpoint get: 'keyA') equals: 10 asString.
	stick endpoint decr: 'keyA'.
	self assert: (stick endpoint get: 'keyA') equals: 9 asString