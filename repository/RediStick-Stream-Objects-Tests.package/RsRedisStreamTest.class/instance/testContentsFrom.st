tests
testContentsFrom
	| strm conts fifteen fifteenToLast seventeen fifteenToSeventeen eighteenToLast |
	strm := self newStreamNamed: 'testContentsFrom'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	1 to: 20 do: [ :idx |
		strm nextPut: idx -> idx.
	].
	conts := strm contents.
	self assert: conts size equals: 20.
	fifteen := conts at: 15.
	fifteenToLast := strm contentsFrom: fifteen id.
	
	self assert: fifteenToLast size equals: 6.
	self assert: conts last content equals: fifteenToLast last content.
	
	seventeen := conts at: 17.
	fifteenToSeventeen := strm contentsFrom: fifteen id to: seventeen id.
	
	self assert: fifteenToSeventeen size equals: 3.
	self assert: fifteenToLast first content equals: fifteenToSeventeen first content.
	
	self assert: (strm contentAt: seventeen id) content equals: '17'->'17'.
	
	eighteenToLast := strm contentsNextFrom: seventeen id count: 3.
	self assert: eighteenToLast size equals: 3.
	self assert: conts last content equals: eighteenToLast last content.
	
	strm trimTo: 0.
	self assert: strm length equals: 0