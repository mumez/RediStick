Class {
	#name : 'RsRedisConnectionPool',
	#superclass : 'Object',
	#instVars : [
		'lock',
		'connections',
		'primaryUrl',
		'secondaryUrl',
		'maxConnectionsPerKey'
	],
	#classInstVars : [
		'default',
		'maxRedisConnectionsPerKey',
		'logger',
		'primaryUrl',
		'secondaryUrl'
	],
	#category : 'RediStick-Connection-Pool',
	#package : 'RediStick-Connection-Pool'
}

{ #category : 'instance creation' }
RsRedisConnectionPool class >> default [
	^default ifNil: [ default := self new ]
]

{ #category : 'class initialization' }
RsRedisConnectionPool class >> initialize [
	default := nil.
	logger := nil.
	
	maxRedisConnectionsPerKey := nil.
	primaryUrl := secondaryUrl := nil.
	
	Smalltalk addToStartUpList: self.
]

{ #category : 'accessing' }
RsRedisConnectionPool class >> logger [
	^logger ifNil: [ logger := SkLocalLogger new ]
]

{ #category : 'accessing' }
RsRedisConnectionPool class >> logger: anLogger [
	^logger := anLogger
]

{ #category : 'accessing' }
RsRedisConnectionPool class >> maxRedisConnectionsPerKey [
	^maxRedisConnectionsPerKey ifNil: [ maxRedisConnectionsPerKey := 5 ]
]

{ #category : 'accessing' }
RsRedisConnectionPool class >> maxRedisConnectionsPerKey: anInteger [
	maxRedisConnectionsPerKey := anInteger
]

{ #category : 'accessing' }
RsRedisConnectionPool class >> primaryUrl [
	^primaryUrl ifNil: [ primaryUrl := 'sync://localhost:6379' ]
]

{ #category : 'accessing' }
RsRedisConnectionPool class >> primaryUrl: aString [
	primaryUrl := aString
]

{ #category : 'accessing' }
RsRedisConnectionPool class >> secondaryUrl [
	^secondaryUrl ifNil: [ secondaryUrl := 'sync://localhost:6380' ]
]

{ #category : 'accessing' }
RsRedisConnectionPool class >> secondaryUrl: aString [
	secondaryUrl := aString
]

{ #category : 'system startup' }
RsRedisConnectionPool class >> startUp: resuming [
	resuming ifFalse: [ ^ self ].
	default ifNotNil: [ default cleanConnections ]
]

{ #category : 'actions' }
RsRedisConnectionPool >> cleanConnections [
	connections keysAndValuesDo: [ :key :eachCol | self pingConnection: (self getConnectionAt: key) at: key ]
]

{ #category : 'actions' }
RsRedisConnectionPool >> connectionDo: aBlock at: key [
	| connection result |
	connection := self getConnectionAt: key.
	result := [ aBlock value: connection ]
		ensure: [ self returnConnection: connection at: key ].
	^ result
]

{ #category : 'factory' }
RsRedisConnectionPool >> createStickAt: key [
	"override"
	| stick |
	stick := RsRediStick targetUrl: self primaryUrl.
	stick beSticky. "beSwitchyWithAll: {self primaryUrl. self secondaryUrl}"
	stick connect.
	^ stick
]

{ #category : 'private' }
RsRedisConnectionPool >> getConnectionAt: key [
	| matchingConnections |
	^ lock
		critical: [ matchingConnections := connections at: key ifAbsentPut: [ OrderedCollection new ].
			matchingConnections ifEmpty: [ matchingConnections add: (self newRedisConnectionAt: key) ].
			matchingConnections removeFirst ]
]

{ #category : 'initialize-release' }
RsRedisConnectionPool >> initialize [
	super initialize.
	lock := Monitor new.
	connections := Dictionary new
]

{ #category : 'logging' }
RsRedisConnectionPool >> logger [
	^self class logger
]

{ #category : 'accessing' }
RsRedisConnectionPool >> maxConnectionsPerKey [
	^maxConnectionsPerKey ifNil: [maxConnectionsPerKey := self class maxRedisConnectionsPerKey]
]

{ #category : 'accessing' }
RsRedisConnectionPool >> maxConnectionsPerKey: anInteger [
	maxConnectionsPerKey := anInteger
]

{ #category : 'factory' }
RsRedisConnectionPool >> newRedisConnectionAt: key [
	^self redisWrapperClass on: (self createStickAt: key)
]

{ #category : 'private' }
RsRedisConnectionPool >> pingConnection: aRedis at: key [
	| pong |
	aRedis ifNil: [ self ].
	pong := [ aRedis ping ]
		on: Error
		do: [ :ex | self logger error: ex. nil ].
	(pong isNil or: [ pong ~= 'PONG' ])
		ifTrue: [ self logger info: 'Destroy redis connection'.
			aRedis destroy ]
		ifFalse: [ self returnConnection: aRedis at: key ]
]

{ #category : 'accessing' }
RsRedisConnectionPool >> primaryUrl [
	^primaryUrl ifNil: [primaryUrl := self class primaryUrl]
]

{ #category : 'accessing' }
RsRedisConnectionPool >> primaryUrl: aString [
	primaryUrl := aString
]

{ #category : 'factory' }
RsRedisConnectionPool >> redisWrapperClass [
	^ RsRedis
]

{ #category : 'actions' }
RsRedisConnectionPool >> releaseConnections [
	connections keysAndValuesDo: [ :key :eachCol | eachCol copy do: [ :each | eachCol remove: each destroy ] ]
]

{ #category : 'private' }
RsRedisConnectionPool >> returnConnection: aRedis at: key [
	lock
		critical: [ | perKeyConnections |
			perKeyConnections := connections at: key.
			perKeyConnections size >= self maxConnectionsPerKey
				ifTrue: [ aRedis destroy ]
				ifFalse: [ perKeyConnections add: aRedis ] ]
]

{ #category : 'accessing' }
RsRedisConnectionPool >> secondaryUrl [
	^secondaryUrl ifNil: [secondaryUrl := self class secondaryUrl]
]

{ #category : 'accessing' }
RsRedisConnectionPool >> secondaryUrl: aString [
	secondaryUrl := aString
]
