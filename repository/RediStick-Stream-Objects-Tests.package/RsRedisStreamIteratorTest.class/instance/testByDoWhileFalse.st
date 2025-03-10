tests
testByDoWhileFalse
	| strm ite1 entries |
	strm := self newStreamNamed: 'testByDoWhileFalse'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	(1 to: 100) doWithIndex: [ :each :idx | 
		strm nextPut: (idx  -> each).
	].
	ite1 := strm iterator.
	entries := OrderedCollection new.
	ite1 by: 5 do: [:ent | entries add: ent ] whileFalse: [:ents :ent | ents size = 5].
	self assert: entries size equals: 4.
	self assert: entries last content equals: ('4'->'4').
	entries := OrderedCollection new.
	ite1 by: 10 do: [:ent | entries add: ent ] whileFalse: [:ents :ent | ent content = ('10'->'10')].
	self assert: entries size equals: 5.
	self assert: entries last content equals: ('9'->'9').
	entries := OrderedCollection new.
	ite1 by: 1 do: [:ent | entries add: ent ] whileFalse: [:ents :ent | entries size > 10 ].
	self assert: entries size equals: 11.
	self assert: entries last content equals: ('20'->'20').
	entries := OrderedCollection new.
	ite1 by: 50 do: [:ent | entries add: ent ] whileFalse: [:ents :ent | ents isEmpty ].
	self assert: entries size equals: 80.
	self assert: entries last id equals: ite1 currentId.
	self assert: strm last id equals: ite1 currentId.
	strm trimTo: 0.
	self assert: strm length equals: 0.