Class {
	#name : 'RsStreamTrimOptions',
	#superclass : 'Object',
	#instVars : [
		'strategy',
		'operator',
		'threshold',
		'limit'
	],
	#category : 'RediStick-Stream',
	#package : 'RediStick-Stream'
}

{ #category : 'converting' }
RsStreamTrimOptions >> asArray [
	| opts |
	self strategy ifNil: [ ^#() ].
	opts := { self strategy } asOrderedCollection.
	self operator ifNotNil: [ :op | opts add: op ].
	opts add: self threshold.
	self limit ifNotNil: [ :li | opts add: li ].
	^ opts asArray
]

{ #category : 'accessing' }
RsStreamTrimOptions >> atLeast: leastValue [
	self operator: '~'.
	self threshold: leastValue.
]

{ #category : 'private' }
RsStreamTrimOptions >> beMaxLen [
	self strategy: 'MAXLEN'
]

{ #category : 'private' }
RsStreamTrimOptions >> beMinId [
	self strategy: 'MINID'
]

{ #category : 'accessing' }
RsStreamTrimOptions >> exactly: value [
	self operator: '='.
	self threshold: value.
]

{ #category : 'accessing' }
RsStreamTrimOptions >> limit [

	^ limit
]

{ #category : 'accessing' }
RsStreamTrimOptions >> limit: anObject [

	limit := anObject
]

{ #category : 'accessing' }
RsStreamTrimOptions >> maxLen: length [
	self beMaxLen.
	self threshold: length.
]

{ #category : 'accessing' }
RsStreamTrimOptions >> maxLenAtLeast: length [
	self beMaxLen.
	self atLeast: length
]

{ #category : 'accessing' }
RsStreamTrimOptions >> minId: id [
	self beMinId.
	self threshold: id asString.
]

{ #category : 'accessing' }
RsStreamTrimOptions >> minIdAtLeast: id [
	self beMinId.
	self atLeast: id asString
]

{ #category : 'accessing' }
RsStreamTrimOptions >> operator [

	^ operator
]

{ #category : 'accessing' }
RsStreamTrimOptions >> operator: anObject [

	operator := anObject
]

{ #category : 'accessing' }
RsStreamTrimOptions >> strategy [

	^ strategy
]

{ #category : 'accessing' }
RsStreamTrimOptions >> strategy: anObject [

	strategy := anObject
]

{ #category : 'accessing' }
RsStreamTrimOptions >> threshold [

	^ threshold
]

{ #category : 'accessing' }
RsStreamTrimOptions >> threshold: anObject [

	threshold := anObject
]
