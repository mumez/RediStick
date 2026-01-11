"
I represent a Redis client with automatic reconnection capabilities using the Stick framework.

Responsibility:
- Manage Redis server connections with automatic reconnection on failure
- Create and configure RsRedisEndpoint instances for Redis communication
- Handle Redis-specific errors through customizable error handlers
- Manage Pub/Sub subscription lifecycle and cleanup on shutdown
- Provide default Redis port configuration (6379)

Collaborators:
- RsRedisEndpoint: I create and manage endpoint instances that execute Redis commands
- RsGenericError: I handle Redis protocol errors via customizable error blocks
- SkStick: I inherit auto-reconnection and connection lifecycle management

Public API and Key Messages:
- #endpoint - Access the current RsRedisEndpoint for executing Redis commands
- #connect - Establish connection to Redis server (inherited from SkStick)
- #pingOk - Test if Redis connection is alive and responding
- #onRedisGenericError: - Configure custom error handling for Redis errors
- #destroy - Clean up resources and close connection (inherited from SkStick)

Internal Representation:
- onRedisGenericErrorBlock - Custom error handler block for Redis protocol errors

Implementation Points:
- Automatically sets port 6379 if not specified in endpoint configuration
- Default error handler logs errors and re-raises NOAUTH exceptions
- Cleanup of Pub/Sub subscriptions occurs on image shutdown and instance destruction
- Error handler receives RsGenericError and stick instance as parameters
- Thread-safe through Stick framework's connection management
"
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
