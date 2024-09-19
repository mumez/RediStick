tests
testNextPutWithMessageId
	| strm one two three four five invalidId conts |
	strm := self newStreamNamed: 'testNextPutWithMessageId'.
	strm beEmptyAndReset.
	self assert: strm length equals: 0.
	one := 'one' -> '1'.
	two := 'two' -> '2'.
	three := 'three' -> '3'.
	four := 'four' -> '4'.
	five := 'five' -> '5'.
	invalidId := RsStreamMessageId epoch.
	self assert: (strm nextPut: one at: invalidId) equals: nil.
	self assert: strm length equals: 0.
	
	strm nextPut: one at: '0-1'.
	strm nextPut: two at: (RsStreamMessageId mainId: 0 subId: 2).
	conts := strm contents.
	self assert: strm length equals: 2.
	self assert: conts first content equals: one.
	self assert: conts second content equals: two.
	
	strm nextPut: three at: (RsStreamMessageId mainIdOnly: 1).
	strm nextPut: four at: (RsStreamMessageId mainIdSubIncremented: 1).
	self assert: (strm nextPut: five at: (RsStreamMessageId mainIdOnly: 1)) equals: nil.
	conts := strm contents.
	self assert: strm length equals: 4.
	self assert: conts first content equals: one.
	self assert: conts last content equals: four.
	self assert: (conts collect: [ :each | each id ]) asArray equals: #('0-1' '0-2' '1-0' '1-1').
	self assert: strm info lastGeneratedId equals: '1-1'.
	
	strm trimLowerThan: (RsStreamMessageId mainId: 1 subId: 0).
	conts := strm contents.
	self assert: strm length equals: 2.
	self assert: conts first content equals: three.
	self assert: conts last content equals: four.
	
	strm trimTo: 0.
	self assert: strm length equals: 0