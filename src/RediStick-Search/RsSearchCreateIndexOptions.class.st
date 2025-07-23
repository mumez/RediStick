Class {
	#name : 'RsSearchCreateIndexOptions',
	#superclass : 'RsBaseSearchOptions',
	#category : 'RediStick-Search',
	#package : 'RediStick-Search'
}

{ #category : 'actions' }
RsSearchCreateIndexOptions >> basicPrefix: aCount with: prefixes [
	self options
		addAll: {
				'PREFIX'.
				aCount asString };
		addAll: prefixes
]

{ #category : 'actions' }
RsSearchCreateIndexOptions >> basicStopwords: aCount with: stopwords [
	self options
		addAll: {
				'STOPWORDS'.
				aCount asString };
		addAll: stopwords
]

{ #category : 'actions' }
RsSearchCreateIndexOptions >> filter: aFilter [
	self options addAll: {
			'FILTER'.
			aFilter asString }
]

{ #category : 'actions' }
RsSearchCreateIndexOptions >> language: aLanguage [
	self options addAll: {
			'LANGUAGE'.
			aLanguage asString }
]

{ #category : 'actions' }
RsSearchCreateIndexOptions >> languageField: aLanguageField [
	self options addAll: {
			'LANGUAGE_FIELD'.
			aLanguageField asString }
]

{ #category : 'actions' }
RsSearchCreateIndexOptions >> maxTextFields [
    self options add: 'MAXTEXTFIELDS'.
]

{ #category : 'actions' }
RsSearchCreateIndexOptions >> noFields [
    self options add: 'NOFIELDS'.
]

{ #category : 'actions' }
RsSearchCreateIndexOptions >> noFreqs [
    self options add: 'NOFREQS'.
]

{ #category : 'actions' }
RsSearchCreateIndexOptions >> noHl [
    self options add: 'NOHL'.
]

{ #category : 'actions' }
RsSearchCreateIndexOptions >> noOffsets [
    self options add: 'NOOFFSETS'.
]

{ #category : 'actions' }
RsSearchCreateIndexOptions >> onHash [
    self options add: 'ON'; add: 'HASH'.
]

{ #category : 'actions' }
RsSearchCreateIndexOptions >> onJson [
    self options add: 'ON'; add: 'JSON'.
]

{ #category : 'actions' }
RsSearchCreateIndexOptions >> payloadField: aPayloadField [
	self options addAll: {
			'PAYLOAD_FIELD'.
			aPayloadField asString }
]

{ #category : 'actions' }
RsSearchCreateIndexOptions >> prefixes: prefixes [
    self basicPrefix: prefixes size with: prefixes
]

{ #category : 'actions' }
RsSearchCreateIndexOptions >> score: aScore [
	self options addAll: {
			'SCORE'.
			aScore asString }
]

{ #category : 'actions' }
RsSearchCreateIndexOptions >> scoreField: aScoreField [
	self options addAll: {
			'SCORE_FIELD'.
			aScoreField asString }
]

{ #category : 'actions' }
RsSearchCreateIndexOptions >> skipInitialScan [
    self options add: 'SKIPINITIALSCAN'.
]

{ #category : 'actions' }
RsSearchCreateIndexOptions >> stopwords: stopwords [
    self basicStopwords: stopwords size with: stopwords
]

{ #category : 'actions' }
RsSearchCreateIndexOptions >> temporary: aTemporaryValue [
	self options addAll: {
			'TEMPORARY'.
			aTemporaryValue asString }
]
