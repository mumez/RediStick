loading
loadValueFromChunk: aValue hints: consumingHints
	(self isEnabled: #withScores in: consumingHints) ifTrue: [
		self score: aValue.
		^ consumingHints removeKey: #withScores ].
	(self isEnabled: #withPayloads in: consumingHints) ifTrue: [
		self payloads: aValue.
		^ consumingHints removeKey: #withPayloads ].
	(self isEnabled: #withSortKeys in: consumingHints) ifTrue: [
		self sortKeys: aValue.
		^ consumingHints removeKey: #withSortKeys ].
	(self isEnabled: #withContent in: consumingHints) ifTrue: [
		self content: aValue.
		^ consumingHints removeKey: #withContent ]