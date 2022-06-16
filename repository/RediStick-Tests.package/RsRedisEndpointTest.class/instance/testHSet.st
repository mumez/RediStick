tests
testHSet
	| value |
	value := self newDateAndTimeValue.
	stick endpoint hSet: 'testHSet' field: 'field1'  value: value.
	self assert: (stick endpoint hGetAll: 'testHSet') equals:  (Dictionary with: ('field1' -> value))