Class {
	#name : 'RsStreamGroupReadOptions',
	#superclass : 'RsStreamReadOptions',
	#instVars : [
		'noAck'
	],
	#category : 'RediStick-Stream',
	#package : 'RediStick-Stream'
}

{ #category : 'converting' }
RsStreamGroupReadOptions >> asArray [
	| opts |
	opts := super asArray.
	self noAck ifNotNil: [ :op | opts := opts , {'NOACK'} ].
	^ opts
]

{ #category : 'accessing' }
RsStreamGroupReadOptions >> noAck [

	^ noAck
]

{ #category : 'accessing' }
RsStreamGroupReadOptions >> noAck: anObject [

	noAck := anObject
]
