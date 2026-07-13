Class {
	#name : 'RsTsCreateOptions',
	#superclass : 'Object',
	#instVars : [
		'retention',
		'encoding',
		'chunkSize',
		'duplicatePolicy',
		'labels'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'converting' }
RsTsCreateOptions >> asArray [
	| opts |
	opts := {} asOrderedCollection.
	self retention ifNotNil: [ :op | opts addAll: { 'RETENTION'. op } ].
	self encoding ifNotNil: [ :op | opts addAll: { 'ENCODING'. op } ].
	self chunkSize ifNotNil: [ :op | opts addAll: { 'CHUNK_SIZE'. op } ].
	self duplicatePolicy ifNotNil: [ :op | opts addAll: { 'DUPLICATE_POLICY'. op } ].
	^ opts asArray
]

{ #category : 'accessing' }
RsTsCreateOptions >> chunkSize [

	^ chunkSize
]

{ #category : 'accessing' }
RsTsCreateOptions >> chunkSize: anObject [

	chunkSize := anObject
]

{ #category : 'accessing' }
RsTsCreateOptions >> duplicatePolicy [

	^ duplicatePolicy
]

{ #category : 'accessing' }
RsTsCreateOptions >> duplicatePolicy: anObject [

	duplicatePolicy := anObject
]

{ #category : 'accessing' }
RsTsCreateOptions >> encoding [

	^ encoding
]

{ #category : 'accessing' }
RsTsCreateOptions >> encoding: anObject [

	encoding := anObject
]

{ #category : 'accessing' }
RsTsCreateOptions >> labels [

	^ labels
]

{ #category : 'accessing' }
RsTsCreateOptions >> labels: anObject [

	labels := anObject asDictionary
]

{ #category : 'accessing' }
RsTsCreateOptions >> retention [

	^ retention
]

{ #category : 'accessing' }
RsTsCreateOptions >> retention: anObject [

	retention := anObject
]
