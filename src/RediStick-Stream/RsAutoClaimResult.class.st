Class {
	#name : 'RsAutoClaimResult',
	#superclass : 'RsStreamObject',
	#instVars : [
		'nextId',
		'claimedMessages',
		'deletedMessages'
	],
	#category : 'RediStick-Stream',
	#package : 'RediStick-Stream'
}

{ #category : 'accessing' }
RsAutoClaimResult >> claimedMessages [

	^ claimedMessages
]

{ #category : 'accessing' }
RsAutoClaimResult >> claimedMessages: anObject [

	claimedMessages := anObject
]

{ #category : 'accessing' }
RsAutoClaimResult >> deletedMessages [

	^ deletedMessages
]

{ #category : 'accessing' }
RsAutoClaimResult >> deletedMessages: anObject [

	deletedMessages := anObject
]

{ #category : 'initialization' }
RsAutoClaimResult >> initClaimedMessages: rawValues [
	self claimedMessages: (rawValues collect: [ :each |
			 each isString
				 ifTrue: [ each ]
				 ifFalse: [ RsStreamEntry fromOrderedCollection: each ] ])
]

{ #category : 'initialization' }
RsAutoClaimResult >> initFromOrderedCollection: rawValues [
	self nextId: rawValues first.
	self initClaimedMessages: rawValues second.
	self deletedMessages: rawValues third
]

{ #category : 'accessing' }
RsAutoClaimResult >> nextId [

	^ nextId
]

{ #category : 'accessing' }
RsAutoClaimResult >> nextId: anObject [

	nextId := anObject
]

{ #category : 'printing' }
RsAutoClaimResult >> printOn: aStream [
	aStream nextPutAll: 'nextId: '.
	self nextId printOn: aStream.
	aStream cr; nextPutAll: 'claimedMessages: '.
	self claimedMessages printOn: aStream.
	aStream cr; nextPutAll: 'deletedMessages: '.
	self deletedMessages printOn: aStream.
]
