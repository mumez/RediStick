tests
testLPos
	| listName pos positions |
	listName := 'testLPos'.
	0 to: 10 do: [ :idx |
		stick endpoint rPush: listName value: idx.
	].
	0 to: 10 do: [ :idx |
		stick endpoint rPush: listName value: idx.
	].
	
	pos := stick endpoint lPos: listName value: '2'.
	self assert: pos equals: 2.
	
	pos := stick endpoint lPosBackward: listName value: '2' maxlen: 10.
	self assert: pos equals: 13.
	
	pos := stick endpoint lPosBackward: listName value: '2' maxlen: 5.
	self assert: pos isNil.
	
	positions := stick endpoint lPos: listName value: '2' count: 0.
	self assertCollection: positions asArray equals: #(2 13)