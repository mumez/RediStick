tests
testLInsert
	| listName elems1 elems2 |
	listName := 'testLInsert'.
	#('one' 'two' 'three') do: [ :each |
		stick endpoint rPush: listName value: each.
	].
	
	stick endpoint lInsert: listName value: 'val1' after: 'two'.
	elems1 := stick endpoint lRange: listName start: 0 end: -1.
	
	self assertCollection: elems1 asArray equals: #('one' 'two' 'val1' 'three').
	
	stick endpoint lInsert: listName value: 'val2' before: 'two'.
	elems2 := stick endpoint lRange: listName start: 0 end: -1.
	
	self assertCollection: elems2 asArray equals: #('one' 'val2' 'two' 'val1' 'three')
	