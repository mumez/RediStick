converting
searchResultParseHints
	^{
		#withId -> true.
		#withScores -> (self optionsDict at: #withScores ifAbsent: [ false ]).
		#withPayloads -> (self optionsDict at: #withPayloads ifAbsent: [ false ]).
		#withSortKeys -> (self optionsDict at: #withSortKeys ifAbsent: [ false ]).
		#withContent -> (self optionsDict at: #noContent ifAbsent: [ false ]) not.
	} asDictionary 