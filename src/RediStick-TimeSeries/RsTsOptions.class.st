Class {
	#name : 'RsTsOptions',
	#superclass : 'Object',
	#instVars : [
		'retention',
		'encoding',
		'chunkSize',
		'labels'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'converting' }
RsTsOptions >> asArray [
	| opts |
	opts := OrderedCollection new.
	self retention ifNotNil: [ :op | opts addAll: { 'RETENTION'. op } ].
	self encoding ifNotNil: [ :op | opts addAll: { 'ENCODING'. op } ].
	self chunkSize ifNotNil: [ :op | opts addAll: { 'CHUNK_SIZE'. op } ].
	^ opts asArray
]

{ #category : 'accessing' }
RsTsOptions >> chunkSize [

	^ chunkSize
]

{ #category : 'accessing' }
RsTsOptions >> chunkSize: anObject [

	chunkSize := anObject
]

{ #category : 'accessing' }
RsTsOptions >> encoding [

	^ encoding
]

{ #category : 'accessing' }
RsTsOptions >> encoding: anObject [

	encoding := anObject
]

{ #category : 'accessing' }
RsTsOptions >> labels [

	^ labels
]

{ #category : 'accessing' }
RsTsOptions >> labels: anObject [

	labels := anObject asDictionary
]

{ #category : 'accessing' }
RsTsOptions >> retention [

	^ retention
]

{ #category : 'accessing' }
RsTsOptions >> retention: anObject [

	retention := anObject
]
