tests
testLMove
	| listName1 listName2 elems1 elems2 |
	listName1 := 'testLMove1'.
	1 to: 3 do: [ :idx |
		stick endpoint rPush: listName1 value: idx.
	].
	listName2 := 'testLMove2'.
	1 to: 3 do: [ :idx |
		stick endpoint rPush: listName2 value: idx*10.
	].
	
	stick endpoint lMoveFrom: listName1 to: listName2.
	
	elems1 := stick endpoint lRange: listName1 start: 0 end: -1.
	elems2 := stick endpoint lRange: listName2 start: 0 end: -1.
	
	self assertCollection: elems1 asArray equals: #('1' '2').
	self assertCollection: elems2 asArray equals: #('3' '10' '20' '30').
	
	stick endpoint lMoveFrom: listName2 removing: 'LEFT' to: listName1 adding: 'RIGHT'.
	
	elems1 := stick endpoint lRange: listName1 start: 0 end: -1.
	elems2 := stick endpoint lRange: listName2 start: 0 end: -1.
	
	self assertCollection: elems1 asArray equals: #('1' '2' '3').
	self assertCollection: elems2 asArray equals: #('10' '20' '30').