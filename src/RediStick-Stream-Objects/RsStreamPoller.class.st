Class {
	#name : 'RsStreamPoller',
	#superclass : 'RsStreamBasePoller',
	#instVars : [
		'stream'
	],
	#category : 'RediStick-Stream-Objects',
	#package : 'RediStick-Stream-Objects'
}

{ #category : 'instance creation' }
RsStreamPoller class >> on: aStream [
	^ self new initStream: aStream; yourself
]

{ #category : 'instance creation' }
RsStreamPoller class >> on: aRsStream nextFrom: fromId [
	^ (self on: aRsStream) currentId: fromId; yourself
]

{ #category : 'private' }
RsStreamPoller >> basicPoll [

	^ self currentId
		  ifNil: [
			  self stream
				  comingAtMost: self readChunkSize
				  waitFor: self waitMilliseconds ]
		  ifNotNil: [
			  self stream
				  nextAtMost: self readChunkSize
				  after: self currentId asStreamMessageId
				  waitFor: self waitMilliseconds ]
]

{ #category : 'initialization' }
RsStreamPoller >> initStream: aRsStream [
	stream := aRsStream sameNamed
]

{ #category : 'private' }
RsStreamPoller >> refresh [
	self refreshStream
]

{ #category : 'initialization' }
RsStreamPoller >> refreshStream [
	stream := stream sameNamed
]

{ #category : 'accessing' }
RsStreamPoller >> stream [
	^ stream
]

{ #category : 'accessing' }
RsStreamPoller >> stream: anObject [

	stream := anObject
]
