actions
nextAtMost: step do: aBlock
	| entries |
	entries := self nextAtMost: step after: self currentId.
	entries do: [ :each |
		aBlock value: each.
		self currentId: each id ]