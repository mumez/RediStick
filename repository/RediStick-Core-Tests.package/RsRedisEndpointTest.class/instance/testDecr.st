tests
testDecr
	self endpoint set: 'keyA' value: 10.
	self assert: (self endpoint get: 'keyA') equals: 10 asString.
	self endpoint decr: 'keyA'.
	self assert: (self endpoint get: 'keyA') equals: 9 asString