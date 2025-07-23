Class {
	#name : 'RsRedisProxy',
	#superclass : 'ProtoObject',
	#instVars : [
		'connectionKey',
		'connectionPool'
	],
	#category : 'RediStick-Connection-Pool',
	#package : 'RediStick-Connection-Pool'
}

{ #category : 'shortcuts' }
RsRedisProxy class >> default [
	^self of: #default
]

{ #category : 'instance creation' }
RsRedisProxy class >> of: redisConnectionKey [
	^self new connectionKey: redisConnectionKey
]

{ #category : 'shortcuts' }
RsRedisProxy class >> pubsub [
	^self of: #pubsub
]

{ #category : 'shortcuts' }
RsRedisProxy class >> session [
	^self of: #session
]

{ #category : 'accessing' }
RsRedisProxy >> connectionKey [
	^ connectionKey
]

{ #category : 'accessing' }
RsRedisProxy >> connectionKey: anObject [
	connectionKey := anObject
]

{ #category : 'factory' }
RsRedisProxy >> connectionPool [
	^ connectionPool ifNil: [connectionPool := self connectionPoolClass default]
]

{ #category : 'factory' }
RsRedisProxy >> connectionPool: aRedisConnectionPool [
	connectionPool := aRedisConnectionPool
]

{ #category : 'factory' }
RsRedisProxy >> connectionPoolClass [
	"override"
	^ RsRedisConnectionPool
]

{ #category : 'reflective operations' }
RsRedisProxy >> doesNotUnderstand: aMessage [ 
	| pool |
	pool := self connectionPool.
	pool ifNil: [ ^super doesNotUnderstand: aMessage  ].
	
	^ pool connectionDo: [:redis | redis perform: aMessage selector withEnoughArguments: aMessage arguments ] at: self connectionKey
]

{ #category : 'class membership' }
RsRedisProxy >> isKindOf: aClass [
	^ self class includesBehavior: aClass
]
