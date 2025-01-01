actions
collect: aBlock
	| entries |
	entries := OrderedCollection new.
	self do: [ :each | entries add: (aBlock value: each) ].
	^ entries