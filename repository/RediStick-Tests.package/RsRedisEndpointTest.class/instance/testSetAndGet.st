tests
testSetAndGet
	| value |
	value := self newDateAndTimeValue.
	stick endpoint set: 'testSet' value: value.
	self assert: (stick endpoint get: 'testSet') equals: value