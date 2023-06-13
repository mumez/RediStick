loading
loadResultsFrom: anArray
	| resultCol |
	resultCol := OrderedCollection new.
	anArray pairsDo: [ :id :cont |
		resultCol add: (RsSearchResult id: id content: cont)
	].
	self results: resultCol 