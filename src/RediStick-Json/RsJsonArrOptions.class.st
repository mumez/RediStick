Class {
	#name : 'RsJsonArrOptions',
	#superclass : 'Object',
	#instVars : [
		'start',
		'stop',
		'index'
	],
	#category : 'RediStick-Json',
	#package : 'RediStick-Json'
}

{ #category : 'converting' }
RsJsonArrOptions >> asArray [
	| opts |
	opts := {} asOrderedCollection.
	self start ifNotNil: [ :op | opts add: op ].
	self stop ifNotNil: [ :op | opts add: op ].
	self index ifNotNil: [ :op | opts add: op ].
	^ opts asArray
]

{ #category : 'accessing' }
RsJsonArrOptions >> index [

	^ index
]

{ #category : 'accessing' }
RsJsonArrOptions >> index: anObject [

	index := anObject
]

{ #category : 'accessing' }
RsJsonArrOptions >> start [

	^ start
]

{ #category : 'accessing' }
RsJsonArrOptions >> start: anObject [

	start := anObject
]

{ #category : 'accessing' }
RsJsonArrOptions >> stop [

	^ stop
]

{ #category : 'accessing' }
RsJsonArrOptions >> stop: anObject [

	stop := anObject
]