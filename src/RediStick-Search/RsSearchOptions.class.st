Class {
	#name : 'RsSearchOptions',
	#superclass : 'RsBaseSearchOptions',
	#category : 'RediStick-Search',
	#package : 'RediStick-Search'
}

{ #category : 'actions' }
RsSearchOptions >> count [
	self offset: 0 limit: 0
]

{ #category : 'actions' }
RsSearchOptions >> dialect: aDialect [
	self options addAll: {
				'DIALECT'.
				aDialect asString }.
]

{ #category : 'actions' }
RsSearchOptions >> expander: anExpander [
	self options addAll: {
				'EXPANDER'.
				anExpander asString }.
]

{ #category : 'actions' }
RsSearchOptions >> explainScore [
	self options add: 'EXPLAINSCORE'.
]

{ #category : 'actions' }
RsSearchOptions >> filter: aNumericField min: aMin max: aMax [
    self options addAll: {
				'FILTER'.
				aNumericField asString.
				aMin asString.
				aMax asString }.
]

{ #category : 'actions' }
RsSearchOptions >> geoFilter: aGeoField lon: aLon lat: aLat radius: aRadius unit: aUnit [
    self options addAll: {
				'GEOFILTER'.
				aGeoField asString.
				aLon asString.
				aLat asString.
				aRadius asString.
				aUnit asString }.
]

{ #category : 'actions' }
RsSearchOptions >> highlightFields: aCount with: fields tags: tags [
	self options
		addAll: {
				'HIGHLIGHT'.
				'FIELDS'.
				aCount asString };
		addAll: fields;
		addAll: {
				'TAGS'.
				tags first asString.
				tags second asString }.
]

{ #category : 'actions' }
RsSearchOptions >> inFields: fields [
    self options
		addAll: {
				'INFIELDS'.
				fields size asString };
		addAll: fields.
]

{ #category : 'actions' }
RsSearchOptions >> inKeys: keys [
    self options
		addAll: {
				'INKEYS'.
				keys size asString };
		addAll: keys.
]

{ #category : 'actions' }
RsSearchOptions >> inOrder [
	self options add: 'INORDER'.
]

{ #category : 'actions' }
RsSearchOptions >> language: aLanguage [
	self options addAll: {
				'LANGUAGE'.
				aLanguage asString }.
]

{ #category : 'actions' }
RsSearchOptions >> limit: num [
	self offset: 0 limit: num
]

{ #category : 'actions' }
RsSearchOptions >> noContent [
    self options add: 'NOCONTENT'.
    self optionsDict at: #noContent put: true
]

{ #category : 'actions' }
RsSearchOptions >> noStopwords [
    self options add: 'NOSTOPWORDS'.
]

{ #category : 'actions' }
RsSearchOptions >> offset: offset [
	self offset: offset limit: 1000
]

{ #category : 'actions' }
RsSearchOptions >> offset: offset limit: num [
	self options addAll: {
				'LIMIT'.
				offset asString.
				num asString }.
]

{ #category : 'actions' }
RsSearchOptions >> params: nameAndValuesDict [
	| nameAndValues |
	nameAndValues := nameAndValuesDict associations gather: [ :each | {each key. each value} ].
	self options
		addAll: {
				'PARAMS'.
				nameAndValues size asString };
		addAll: nameAndValues
]

{ #category : 'actions' }
RsSearchOptions >> payload: aPayload [
	self options addAll: {
				'PAYLOAD'.
				aPayload asString }.
]

{ #category : 'actions' }
RsSearchOptions >> returnFields: searchIndexFields [
	| args |
	args := OrderedCollection new.
	searchIndexFields do: [ :each | each createArgumentsOn: args ].
	self options
		addAll: {
				'RETURN'.
				searchIndexFields size asString };
		addAll: args.
]

{ #category : 'actions' }
RsSearchOptions >> scorer: aScorer [
	self options addAll: {
				'SCORER'.
				aScorer asString }.
]

{ #category : 'converting' }
RsSearchOptions >> searchResultParseHints [
	^{
		#withId -> true.
		#withScores -> (self optionsDict at: #withScores ifAbsent: [ false ]).
		#withPayloads -> (self optionsDict at: #withPayloads ifAbsent: [ false ]).
		#withSortKeys -> (self optionsDict at: #withSortKeys ifAbsent: [ false ]).
		#withContent -> (self optionsDict at: #noContent ifAbsent: [ false ]) not.
	} asDictionary 
]

{ #category : 'actions' }
RsSearchOptions >> slop: aSlop [
	self options addAll: {
				'SLOP'.
				aSlop asString }.
]

{ #category : 'actions' }
RsSearchOptions >> sortBy: sortBy ascOrDesc: ascOrDesc [
	self options addAll: {
				'SORTBY'.
				sortBy asString.
				ascOrDesc asString }.
]

{ #category : 'actions' }
RsSearchOptions >> sortByAsc: attribute [ 
	self sortBy: attribute ascOrDesc: 'ASC'
]

{ #category : 'actions' }
RsSearchOptions >> sortByDesc: attribute [ 
	self sortBy: attribute ascOrDesc: 'DESC'
]

{ #category : 'actions' }
RsSearchOptions >> summarizeFields: aCount with: fields frags: num len: fragsize separator: separator [
	self options
		addAll: {
				'SUMMARIZE'.
				'FIELDS'.
				aCount asString };
		addAll: fields;
		addAll: {
				'FRAGS'.
				num asString.
				'LEN'.
				fragsize asString.
				'SEPARATOR'.
				separator asString }.
]

{ #category : 'actions' }
RsSearchOptions >> timeout: aTimeout [
	self options addAll: {
				'TIMEOUT'.
				aTimeout asString }.
]

{ #category : 'actions' }
RsSearchOptions >> verbatim [
    self options add: 'VERBATIM'.
]

{ #category : 'actions' }
RsSearchOptions >> withPayloads [
	self options add: 'WITHPAYLOADS'.
	self optionsDict at: #withPayloads put: true
]

{ #category : 'actions' }
RsSearchOptions >> withScores [
    self options add: 'WITHSCORES'.
    self optionsDict at: #withScores put: true
]

{ #category : 'actions' }
RsSearchOptions >> withSortKeys [
    self options add: 'WITHSORTKEYS'.
    self optionsDict at: #withSortKeys put: true
]
