actions
collect: aBlock
	| entries |
	entries := OrderedCollection new.
	self do: [ :each | entries add: each ].
	^ entries