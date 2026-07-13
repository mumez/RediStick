Class {
	#name : 'RsTsAddOptions',
	#superclass : 'Object',
	#instVars : [
		'retention',
		'encoding',
		'chunkSize',
		'onDuplicate',
		'labels'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'converting' }
RsTsAddOptions >> asArray [
	| opts |
	opts := {} asOrderedCollection.
	self retention ifNotNil: [ :op | opts addAll: { 'RETENTION'. op } ].
	self encoding ifNotNil: [ :op | opts addAll: { 'ENCODING'. op } ].
	self chunkSize ifNotNil: [ :op | opts addAll: { 'CHUNK_SIZE'. op } ].
	self onDuplicate ifNotNil: [ :op | opts addAll: { 'ON_DUPLICATE'. op } ].
	^ opts asArray
]

{ #category : 'accessing' }
RsTsAddOptions >> chunkSize [

	^ chunkSize
]

{ #category : 'accessing' }
RsTsAddOptions >> chunkSize: anObject [

	chunkSize := anObject
]

{ #category : 'accessing' }
RsTsAddOptions >> encoding [

	^ encoding
]

{ #category : 'accessing' }
RsTsAddOptions >> encoding: anObject [

	encoding := anObject
]

{ #category : 'accessing' }
RsTsAddOptions >> labels [

	^ labels
]

{ #category : 'accessing' }
RsTsAddOptions >> labels: anObject [

	labels := anObject asDictionary
]

{ #category : 'accessing' }
RsTsAddOptions >> onDuplicate [

	^ onDuplicate
]

{ #category : 'accessing' }
RsTsAddOptions >> onDuplicate: anObject [

	onDuplicate := anObject
]

{ #category : 'accessing' }
RsTsAddOptions >> retention [

	^ retention
]

{ #category : 'accessing' }
RsTsAddOptions >> retention: anObject [

	retention := anObject
]
