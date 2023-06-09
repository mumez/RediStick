loading
loadResultsFrom: anArray parseHints: parseHints
	| resultCol chunkSize readStream |
	resultCol := OrderedCollection new.
	chunkSize := (parseHints values select: [ :e | e ]) size.
	
	readStream := anArray readStream.
	[ readStream atEnd ] whileFalse: [ | chunk |
		chunk := readStream next: chunkSize.
		resultCol add: (RsSearchResult fromChunk: chunk parseHints: parseHints)
	].

	self results: resultCol

