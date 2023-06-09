loading
loadValueFromChunk: aValue hints: consumingHints

	(consumingHints includesKey: #withScores) ifTrue: [
		self score: aValue.
		^ consumingHints removeKey: #withScores ].
	(consumingHints includesKey: #withPayloads) ifTrue: [
		self payloads: aValue.
		^ consumingHints removeKey: #withPayloads ].
	(consumingHints includesKey: #withSortKeys) ifTrue: [
		self sortKeys: aValue.
		^ consumingHints removeKey: #withSortKeys ].
	(consumingHints includesKey: #withContent) ifTrue: [
		self content: aValue.
		^ consumingHints removeKey: #withContent ]