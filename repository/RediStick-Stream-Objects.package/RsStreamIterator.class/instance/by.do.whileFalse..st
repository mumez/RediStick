actions
by: step do: aBlock whileFalse: endConditionBlock
	| entries |
	entries := self endpoint
		           xRange: self streamName
		           nextFrom: self currentId
		           count: step.

	entries do: [ :each |
		aBlock value: each.
		self currentId: each id ].

	( endConditionBlock cull: entries cull: self currentId ) ifFalse: [
		self by: step do: aBlock whileFalse: endConditionBlock ]