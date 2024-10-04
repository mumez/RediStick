actions
by: step do: aBlock whileFalse: endConditionBlock
	| entries |
	entries := self entriesFrom: self currentId count: step.
	entries do: [ :each |
		aBlock value: each.
		self currentId: each id ].
	( endConditionBlock cull: entries cull: self currentId ) ifFalse: [
		self by: step do: aBlock whileFalse: endConditionBlock ]