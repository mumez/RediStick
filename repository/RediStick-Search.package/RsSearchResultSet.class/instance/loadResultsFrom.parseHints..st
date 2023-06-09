loading
loadResultsFrom: anArray parseHints: parseHints
	| resultCol |
	resultCol := OrderedCollection new.
	parseHints inspect.
	anArray pairsDo: [ :id :cont |
		resultCol add: (RsSearchResult id: id first content: (Dictionary newFromPairs: cont))
	].
	self results: resultCol 