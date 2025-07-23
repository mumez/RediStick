Class {
	#name : 'RsStreamClaimOptions',
	#superclass : 'Object',
	#instVars : [
		'idleMilliseconds',
		'idleTimeAt',
		'retryCount',
		'idsOnly',
		'lastId',
		'forceCreate'
	],
	#category : 'RediStick-Stream',
	#package : 'RediStick-Stream'
}

{ #category : 'converting' }
RsStreamClaimOptions >> asArray [
	| opts |
	opts := {} asOrderedCollection.
	self idleMilliseconds ifNotNil: [ :op | opts addAll: {'IDLE'. op} ].
	self idleTimeAt  ifNotNil: [ :op | opts addAll: {'TIME'. op} ].
	self retryCount ifNotNil: [ :op | opts addAll: {'RETRYCOUNT'. op} ].
	self forceCreate ifTrue: [ opts add: 'FORCE' ].
	self idsOnly ifTrue: [ opts add: 'JUSTID' ].
	self lastId ifNotNil: [ :op | opts addAll: {'LASTID'. op} ].
	^ opts asArray
]

{ #category : 'accessing' }
RsStreamClaimOptions >> forceCreate [

	^ forceCreate ifNil: [ forceCreate := false ]
]

{ #category : 'accessing' }
RsStreamClaimOptions >> forceCreate: anObject [

	forceCreate := anObject
]

{ #category : 'accessing' }
RsStreamClaimOptions >> idleMilliseconds [

	^ idleMilliseconds
]

{ #category : 'accessing' }
RsStreamClaimOptions >> idleMilliseconds: anObject [

	idleMilliseconds := anObject
]

{ #category : 'accessing' }
RsStreamClaimOptions >> idleTimeAt [

	^ idleTimeAt
]

{ #category : 'accessing' }
RsStreamClaimOptions >> idleTimeAt: anObject [

	idleTimeAt := anObject
]

{ #category : 'accessing' }
RsStreamClaimOptions >> idsOnly [

	^ idsOnly ifNil: [ idsOnly := false ]
]

{ #category : 'accessing' }
RsStreamClaimOptions >> idsOnly: anObject [

	idsOnly := anObject
]

{ #category : 'accessing' }
RsStreamClaimOptions >> lastId [

	^ lastId
]

{ #category : 'accessing' }
RsStreamClaimOptions >> lastId: anObject [

	lastId := anObject
]

{ #category : 'accessing' }
RsStreamClaimOptions >> retryCount [

	^ retryCount
]

{ #category : 'accessing' }
RsStreamClaimOptions >> retryCount: anObject [

	retryCount := anObject
]
