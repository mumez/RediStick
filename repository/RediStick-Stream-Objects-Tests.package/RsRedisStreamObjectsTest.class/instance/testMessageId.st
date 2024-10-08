tests
testMessageId
	| id1 id2 id3 |
	self assert: RsStreamMessageId all asString equals: '0'.
	self assert: RsStreamMessageId min asString equals: '-'.
	self assert: RsStreamMessageId max asString equals: '+'.
	self assert: RsStreamMessageId autoGenerated asString equals: '*'.
	self assert: RsStreamMessageId neverDelivered asString equals: '>'.
	self assert: RsStreamMessageId newest asString equals: '$'.
	#(all min max autoGenerated neverDelivered newest) do: [ :sele |
		self assert: (RsStreamMessageId perform: sele) equals: (RsStreamMessageId perform: sele).
	].
	id1 := RsStreamMessageId fromString: 'aaa-1'.
	self assert: id1 equals:(RsStreamMessageId fromString: 'aaa-1').
	self deny: id1 equals:(RsStreamMessageId fromString: 'aaa-2').
	self assert: id1 mainId equals: 'aaa'.
	self assert: id1 subId equals: '1'.
	self assert: id1 isAutoSequence not.
	id2 := RsStreamMessageId fromString: 'aaaaa'.
	self assert: id2 mainId equals: 'aaaaa'.
	self assert: id2 subId equals: nil.
	self assert: id2 isAutoSequence not.
	id3 := RsStreamMessageId idWithAutoSequence: 'bbbbb'.
	self assert: id3 mainId equals: 'bbbbb'.
	self assert: id3 subId equals: '*'.
	self assert: id3 isAutoSequence