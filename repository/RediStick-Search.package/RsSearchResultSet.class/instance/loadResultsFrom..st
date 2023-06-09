loading
loadResultsFrom: anArray
	| resultCol |
	resultCol := OrderedCollection new.
	anArray pairsDo: [ :id :cont |
		resultCol add: (RsSearchResult id: id first content: (Dictionary newFromPairs: cont))
	].
	self results: resultCol 