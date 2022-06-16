tests
testSetAndGet
	| value |
	value := self newDateAndTimeValue.
	stick endpoint set: 'testSetAndGet' value: value.
	self assert: (stick endpoint get: 'testSetAndGet') equals: value