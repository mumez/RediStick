tests
testLPushPop
	| listName elem elems |
	listName := 'testLPushPop'.
	stick endpoint lPush: listName value: 'val1'.
	stick endpoint lPush: listName value: 'val2'.
	stick endpoint lPush: listName value: 'val3'.
	elem := stick endpoint lPop: listName.
	self assert: elem equals: 'val3'.
	
	elems := stick endpoint lPop: listName count: 2.
	self assertCollection: elems asArray equals: #('val2' 'val1').