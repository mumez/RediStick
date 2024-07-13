tests
testComing

	| strm strm2 nextComing nextThree |
	strm := self newStreamNamed: 'testComing'.
	strm2 := self newStreamNamed: 'testComing'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	strm2 nextPut: 0 -> 0.
	[
	(Delay forMilliseconds: 10) wait.
	1 to: 10 do: [ :idx |
		strm2 nextPut: idx -> idx.
		(Delay forMilliseconds: 50) wait ] ] fork.

	nextComing := strm comingAtMost: 3 waitFor: 200.
	self assert: nextComing size equals: 1.
	self assert: nextComing first content equals: '1' -> '1'.

	(Delay forMilliseconds: 300) wait.
	nextThree := strm
		             nextAtMost: 3
		             after: nextComing first id
		             waitFor: 500.
	self assert: nextThree size equals: 3.
	self assert: nextThree first content equals: '2' -> '2'.
	self assert: nextThree second content equals: '3' -> '3'.
	self assert: nextThree third content equals: '4' -> '4'.
	self assert: strm length > 6.
	strm trimTo: 0.
	self assert: strm length equals: 0