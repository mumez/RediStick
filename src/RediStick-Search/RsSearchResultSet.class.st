Class {
	#name : 'RsSearchResultSet',
	#superclass : 'Object',
	#instVars : [
		'total',
		'results'
	],
	#category : 'RediStick-Search',
	#package : 'RediStick-Search'
}

{ #category : 'instance creation' }
RsSearchResultSet class >> fromRawResults: anArray options: options [
	| inst |
	inst := self new.
	inst loadRawResults: anArray options: options.
	^ inst
]

{ #category : 'accessing' }
RsSearchResultSet >> documentIds [
	^self results collect: [ :each | each id ]
]

{ #category : 'loading' }
RsSearchResultSet >> loadIdsFrom: anArray [
	self results: (anArray collect: [:each | RsSearchResult id: each]).
]

{ #category : 'loading' }
RsSearchResultSet >> loadRawResults: anArray options: options [
	| contentsArray parseHints |
	self total: anArray first.
	contentsArray := anArray copyFrom: 2 to: anArray size.
	options ifNil: [ ^ self loadResultsFrom: contentsArray ].
	parseHints := options searchResultParseHints.
	self loadResultsFrom: contentsArray parseHints: parseHints
]

{ #category : 'loading' }
RsSearchResultSet >> loadResultsFrom: anArray [
	| resultCol |
	resultCol := OrderedCollection new.
	anArray pairsDo: [ :id :cont |
		resultCol add: (RsSearchResult id: id content: cont)
	].
	self results: resultCol 
]

{ #category : 'loading' }
RsSearchResultSet >> loadResultsFrom: anArray parseHints: parseHints [
	| resultCol chunkSize readStream |
	resultCol := OrderedCollection new.
	chunkSize := (parseHints values select: [ :e | e ]) size.
	
	readStream := anArray readStream.
	[ readStream atEnd ] whileFalse: [ | chunk |
		chunk := readStream next: chunkSize.
		resultCol add: (RsSearchResult fromChunk: chunk parseHints: parseHints)
	].

	self results: resultCol


]

{ #category : 'accessing' }
RsSearchResultSet >> result [
	self results ifEmpty: [ ^ nil ].
	^ self results at: 1
]

{ #category : 'accessing' }
RsSearchResultSet >> results [

	^ results
]

{ #category : 'accessing' }
RsSearchResultSet >> results: anObject [

	results := anObject
]

{ #category : 'accessing' }
RsSearchResultSet >> size [

	^ self results size
]

{ #category : 'accessing' }
RsSearchResultSet >> total [

	^ total
]

{ #category : 'accessing' }
RsSearchResultSet >> total: anObject [

	total := anObject
]
