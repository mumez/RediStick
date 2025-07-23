Class {
	#name : 'RsPubsubMessage',
	#superclass : 'Object',
	#instVars : [
		'kind',
		'channel',
		'numberOfChannels',
		'payload'
	],
	#category : 'RediStick-Core',
	#package : 'RediStick-Core'
}

{ #category : 'instance creation' }
RsPubsubMessage class >> fromRawMessageArray: messageArray [
	| kind inst |
	kind := messageArray at: 1.
	inst := self new
				kind: kind;
				channel: (messageArray at: 2).
	(kind = 'subscribe' or: [ kind = 'unsubscribe' ])
		ifTrue: [ inst numberOfChannels: (messageArray at: 3)]
		ifFalse: [ inst payload: (messageArray at: 3) ].	
	^inst
	
	
]

{ #category : 'accessing' }
RsPubsubMessage >> channel [
	^ channel
]

{ #category : 'accessing' }
RsPubsubMessage >> channel: anObject [
	channel := anObject
]

{ #category : 'testing' }
RsPubsubMessage >> isNormal [
	^ self kind = 'message'
]

{ #category : 'testing' }
RsPubsubMessage >> isSubscribe [
	^self kind = 'subscribe'
]

{ #category : 'testing' }
RsPubsubMessage >> isUnsubscribe [
	^self kind = 'unsubscribe'
]

{ #category : 'accessing' }
RsPubsubMessage >> kind [
	^ kind
]

{ #category : 'accessing' }
RsPubsubMessage >> kind: anObject [
	kind := anObject
]

{ #category : 'accessing' }
RsPubsubMessage >> numberOfChannels [
	^ numberOfChannels
]

{ #category : 'accessing' }
RsPubsubMessage >> numberOfChannels: anObject [
	numberOfChannels := anObject
]

{ #category : 'accessing' }
RsPubsubMessage >> payload [
	^ payload
]

{ #category : 'accessing' }
RsPubsubMessage >> payload: anObject [
	payload := anObject
]

{ #category : 'printing' }
RsPubsubMessage >> printOn: aStream [
	self kind ifNotNil: [ 
		aStream nextPutAll: ('[', self kind, ']').
	].
	self channel ifNotNil: [ 
		aStream space; nextPutAll:  'Channel: '.
		aStream nextPutAll: self channel asString.
	].
	self numberOfChannels ifNotNil: [ 
		aStream space; nextPutAll:  'NumberOfChannels: '.
		aStream nextPutAll: self numberOfChannels asString.
	].
	self payload ifNotNil: [ 
		aStream space; nextPutAll:  'Payload: '.
		aStream nextPutAll: self payload asString.
	].
	
	
]
