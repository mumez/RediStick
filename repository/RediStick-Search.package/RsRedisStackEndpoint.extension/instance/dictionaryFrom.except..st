*RediStick-Search
dictionaryFrom: pairs except: keys
	| dict |
	dict := Dictionary newFromPairs: pairs.
	dict keysAndValuesDo: [ :k :v |
		((v isMemberOf: OrderedCollection) and: [ (keys includes: k) not ])
			ifTrue: [ dict at: k put: (self dictionaryFrom: v except: #()) ] ].
	^ dict