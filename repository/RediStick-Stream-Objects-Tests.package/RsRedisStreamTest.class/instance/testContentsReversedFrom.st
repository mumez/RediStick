tests
testContentsReversedFrom
	| strm conts fifteen fifteenToFirst seventeen seventeenToFifteen sixteenToFifteen |
	strm := self newStreamNamed: 'testContentsReversedFrom'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	1 to: 20 do: [ :idx |
		strm nextPut: idx -> idx.
	].
	conts := strm contentsReversed.
	self assert: conts size equals: 20.
	fifteen := conts at: 6.
	fifteenToFirst := strm contentsReversedFrom: fifteen id.
	
	self assert: fifteenToFirst size equals: 15.
	self assert: conts last content equals: fifteenToFirst last content.
	
	seventeen := conts at: 4.
	seventeenToFifteen := strm contentsReversedFrom: seventeen id to: fifteen id.
	
	self assert: seventeenToFifteen size equals: 3.
	self assert: fifteenToFirst first content equals: seventeenToFifteen last content.
	
	self assert: (strm contentAt: seventeen id) content equals: '17'->'17'.
	
	sixteenToFifteen := strm contentsReversedNextFrom: seventeen id count: 2.
	self assert: sixteenToFifteen size equals: 2.
	self assert: fifteenToFirst first content equals: sixteenToFifteen last content.
	
	strm trimTo: 0.
	self assert: strm length equals: 0