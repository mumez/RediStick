tests
testLIndex
	| listName elem |
	listName := 'testLIndex'.
	0 to: 4 do: [ :idx |
		stick endpoint rPush: listName value: idx.
	].
	
	elem := stick endpoint lIndex: listName value: 2.
	self assert: elem equals: '2'.
	
	elem := stick endpoint lIndex: listName value: 4.
	self assert: elem equals: '4'.
	
	elem := stick endpoint lIndex: listName value: 10.
	self assert: elem equals: nil.
	
	