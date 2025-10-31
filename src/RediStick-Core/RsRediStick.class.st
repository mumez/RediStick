Class {
	#name : 'RsRediStick',
	#superclass : 'SkStick',
	#instVars : [
		'onRedisGenericErrorBlock'
	],
	#category : 'RediStick-Core',
	#package : 'RediStick-Core'
}

{ #category : 'factory' }
RsRediStick >> createEndpoint [
	| ep |
	ep := super createEndpoint.
	ep remotePortNumber ifNil: [ ep remotePortNumber: 6379 ].
	^ep
]

{ #category : 'defaults' }
RsRediStick >> defaultRedisGenericErrorHandingBlock [
	^ [:ex | 
		self logger error: ex.
		ex isNoAuth ifTrue: [ ex pass ].
	]
]

{ #category : 'releasing' }
RsRediStick >> destroy [
	self releasePubsub.
	super destroy.
]

{ #category : 'factory' }
RsRediStick >> endpointClassForScheme: schemeName [
	^RsRedisEndpoint
]

{ #category : 'startup-shutdown' }
RsRediStick >> onImageQuit [
	self releasePubsub
]

{ #category : 'error handling' }
RsRediStick >> onRedisGenericError: aBlock [
	onRedisGenericErrorBlock := aBlock
]

{ #category : 'accessing' }
RsRediStick >> onRedisGenericErrorBlock [
	^ onRedisGenericErrorBlock ifNil: [ onRedisGenericErrorBlock := self defaultRedisGenericErrorHandingBlock]
]

{ #category : 'error handling' }
RsRediStick >> onRedisGenericErrorSignaled: aRsGenericError [
	self onRedisGenericErrorBlock ifNotNil: [ :block | block cull: aRsGenericError cull: self]
]

{ #category : 'testing' }
RsRediStick >> pingOk [
	^ self endpoint ping = 'PONG'
]

{ #category : 'releasing' }
RsRediStick >> releasePubsub [
	self endpoint ifNotNil: [ :ep | ep isPubsub ifTrue: [ ep releasePubsub ] ]
]
