Class {
	#name : 'RsSearchResult',
	#superclass : 'Object',
	#instVars : [
		'id',
		'score',
		'payloads',
		'sortKeys',
		'content'
	],
	#category : 'RediStick-Search',
	#package : 'RediStick-Search'
}

{ #category : 'instance creation' }
RsSearchResult class >> fromChunk: chunkArray parseHints: parseHints [

	| inst id hints readStream |
	inst := self new.
	id := chunkArray at: 1.
	inst id: id.
	chunkArray size = 1 ifTrue: [ ^ inst ].
	hints := parseHints copy.
	readStream := (chunkArray copyFrom: 2 to: chunkArray size) readStream.
	[ readStream atEnd ] whileFalse: [
		| nextValue |
		nextValue := readStream next.
		inst loadValueFromChunk: nextValue hints: hints ].

	^ inst
]

{ #category : 'instance creation' }
RsSearchResult class >> id: documentId [
	^ self id: documentId content: #()
]

{ #category : 'instance creation' }
RsSearchResult class >> id: documentId content: content [
	^ self new
		  id: documentId;
		  content: content;
		  yourself
]

{ #category : 'accessing' }
RsSearchResult >> content [

	^ content
]

{ #category : 'accessing' }
RsSearchResult >> content: anObject [
	| val |
	val := anObject
		       ifNil: [ anObject ]
		       ifNotNil: [ Dictionary newFromPairs: anObject ].
	content := val
]

{ #category : 'accessing' }
RsSearchResult >> id [

	^ id
]

{ #category : 'accessing' }
RsSearchResult >> id: anObject [

	id := anObject
]

{ #category : 'private' }
RsSearchResult >> isEnabled: key in: consumingHints [
	^ ((consumingHints includesKey: key) and: [consumingHints at: key])
]

{ #category : 'loading' }
RsSearchResult >> loadValueFromChunk: aValue hints: consumingHints [
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
]

{ #category : 'accessing' }
RsSearchResult >> payloads [

	^ payloads
]

{ #category : 'accessing' }
RsSearchResult >> payloads: anObject [

	payloads := anObject
]

{ #category : 'accessing' }
RsSearchResult >> score [

	^ score
]

{ #category : 'accessing' }
RsSearchResult >> score: anObject [
	| val |
	val := anObject isString
		       ifTrue: [ anObject asInteger ]
		       ifFalse: [ anObject ].
	score := val
]

{ #category : 'accessing' }
RsSearchResult >> sortKeys [

	^ sortKeys
]

{ #category : 'accessing' }
RsSearchResult >> sortKeys: anObject [

	sortKeys := anObject
]
