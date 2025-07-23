Class {
	#name : 'RsRedis',
	#superclass : 'Object',
	#instVars : [
		'stick'
	],
	#category : 'RediStick-Connection-Pool',
	#package : 'RediStick-Connection-Pool'
}

{ #category : 'instance creation' }
RsRedis class >> on: aRediStick [
	^self new stick: aRediStick
]

{ #category : 'actions' }
RsRedis >> add: value toSetAt: key [
	key isEmptyOrNil ifTrue: [ self error: 'invalid key' ].
	
	self endpoint sAdd: key member: value.
	^ value

]

{ #category : 'actions-list' }
RsRedis >> addFirst: value toListAt: key [
	key isEmptyOrNil ifTrue: [ self error: 'invalid key' ].
	^ self endpoint lPush: key value: value
]

{ #category : 'actions-list' }
RsRedis >> addLast: value toListAt: key [
	key isEmptyOrNil ifTrue: [ self error: 'invalid key' ].
	self endpoint rPush: key value: value.
	^ value
]

{ #category : 'pubsub' }
RsRedis >> allPubsubChannels [
	^self endpoint pubsubChannels: #()
]

{ #category : 'actions' }
RsRedis >> at: key [ 
	^ self endpoint get: key
]

{ #category : 'actions' }
RsRedis >> at: key ifAbsent: aBlock [
	^ (self at: key) ifNil: [ aBlock value ].
]

{ #category : 'actions' }
RsRedis >> at: key ifAbsentPut: aBlock [
	^ (self at: key) ifNil: [ self at: key put: aBlock value ].
]

{ #category : 'actions' }
RsRedis >> at: key ifAbsentPut: aBlock expiresIn: seconds [
	^ (self at: key)
		ifNil: [ | return |
			return := self at: key put: aBlock value.
			self endpoint expire: key seconds: seconds.
			return ]
]

{ #category : 'actions' }
RsRedis >> at: key put: value [
	key isEmptyOrNil ifTrue: [ self error: 'invalid key' ].

	self endpoint set: key value: value.
	^value

]

{ #category : 'actions' }
RsRedis >> at: key put: value expiresIn: seconds [
	self at: key put: value.
	self  endpoint expire: key seconds: seconds.
	^value

]

{ #category : 'actions' }
RsRedis >> decrementAt: key [
	^ self endpoint decr: key
]

{ #category : 'actions' }
RsRedis >> deleteKey: key [
	^ self endpoint del: { key }
]

{ #category : 'actions' }
RsRedis >> deleteKeys: keys [
	^ self endpoint del: keys
]

{ #category : 'releasing' }
RsRedis >> destroy [
	stick ifNotNil: [stick destroy].
	stick := nil
]

{ #category : 'accessing' }
RsRedis >> endpoint [
	^ self stick endpoint
]

{ #category : 'actions' }
RsRedis >> expire: key in: expireSecs [
	^ self endpoint expire: key seconds: expireSecs
]

{ #category : 'actions-list' }
RsRedis >> firstValueInListAt: key [
	| col |
	key isEmptyOrNil ifTrue: [ self error: 'invalid key' ].
	col := self endpoint lRange: key start: 0 end: 0.
	col isEmptyOrNil ifTrue: [ ^ nil ].
	^ col first
]

{ #category : 'actions' }
RsRedis >> includesKey: key [
	^ self endpoint exists: key
]

{ #category : 'actions' }
RsRedis >> incrementAt: key [
	^ self endpoint incr: key
]

{ #category : 'actions' }
RsRedis >> keys: pattern [
	| keys |
	keys := self endpoint keys: pattern.
	keys ifNil: [ ^ OrderedCollection new ].
	^ keys
]

{ #category : 'pubsub' }
RsRedis >> numberOfSubscribers: channelArray [
	^self endpoint pubsubNumsub: channelArray
]

{ #category : 'actions' }
RsRedis >> ping [
	^ self endpoint ping
]

{ #category : 'pubsub' }
RsRedis >> publish: channel message: message [
	^self endpoint publish: channel asString message: message
]

{ #category : 'actions' }
RsRedis >> sizeOfListAt: key [
	^ (self endpoint lLen: key) ifNil: [ 0 ]
]

{ #category : 'accessing' }
RsRedis >> stick [
	^stick
]

{ #category : 'accessing' }
RsRedis >> stick: aRediStick [
	stick := aRediStick
]

{ #category : 'pubsub' }
RsRedis >> subscribe: channelArray callback: aBlock [ 
	^self endpoint subscribe: (channelArray collect: #asString) callback: aBlock 
]

{ #category : 'pubsub' }
RsRedis >> unsubscribe: channelArray [
	^self endpoint unsubscribe: (channelArray collect: #asString)
]

{ #category : 'actions' }
RsRedis >> valuesAtKeys: pattern [
	| keys |
	keys := self keys: pattern.
	keys ifNil: [ ^ #() ].
	^ (self endpoint mGet: keys) ifNil: [ #() ]
]

{ #category : 'actions' }
RsRedis >> valuesForKeys: keys [
	^(self endpoint mGet: keys) ifNil: [ #() ]
]

{ #category : 'actions' }
RsRedis >> valuesInListAt: key [
	| len |
	len := self endpoint lLen: key.
	^ self endpoint lRange: key start: 0 end: (len - 1)
]

{ #category : 'actions' }
RsRedis >> valuesInSetAt: key [
	^ self endpoint sMembers: key
]
