loading
loadRawResults: anArray options: options
	| contentsArray parseHints |
	self size: anArray first.
	contentsArray := anArray copyFrom: 2 to: anArray size.
	options ifNil: [ ^ self loadResultsFrom: contentsArray ].
	parseHints := options searchResultParseHints.
	self loadResultsFrom: contentsArray parseHints: parseHints