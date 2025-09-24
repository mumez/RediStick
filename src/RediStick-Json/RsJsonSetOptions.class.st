Class {
	#name : 'RsJsonSetOptions',
	#superclass : 'Object',
	#instVars : [
		'mode'
	],
	#category : 'RediStick-Json',
	#package : 'RediStick-Json'
}

{ #category : 'converting' }
RsJsonSetOptions >> asArray [
	self mode ifNil: [ ^#() ].
	^ {self mode}
]

{ #category : 'actions' }
RsJsonSetOptions >> ifAlreadyExists [
	self mode: 'XX'
]

{ #category : 'actions' }
RsJsonSetOptions >> ifNotExists [
	self mode: 'NX'
]

{ #category : 'accessing' }
RsJsonSetOptions >> mode [

	^ mode
]

{ #category : 'accessing' }
RsJsonSetOptions >> mode: anObject [

	mode := anObject
]
