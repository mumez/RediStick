Class {
	#name : 'RsRedisSubscriptionManager',
	#superclass : 'Object',
	#instVars : [
		'intervalSeconds',
		'connectionKeeper',
		'targetUrl',
		'subscriber',
		'maxSubscriberRestorationRetries',
		'onSubscriberNotRestored'
	],
	#classInstVars : [
		'default',
		'logger',
		'subscribeChannelsOnStartup'
	],
	#category : 'RediStick-Pubsub',
	#package : 'RediStick-Pubsub'
}

{ #category : 'instance creation' }
RsRedisSubscriptionManager class >> default [
	^default ifNil: [ default := self new ]
]

{ #category : 'class initialization' }
RsRedisSubscriptionManager class >> initDefault [
	default ifNotNil: [ 
		default shutDown.
	].
	default := nil
]

{ #category : 'class initialization' }
RsRedisSubscriptionManager class >> initialize [
	self initDefault.
	
	logger := nil.
	subscribeChannelsOnStartup := true.
	
	Smalltalk addToStartUpList: self.
	Smalltalk addToShutDownList: self
]

{ #category : 'accessing' }
RsRedisSubscriptionManager class >> logger [
	^logger ifNil: [ logger := SkLocalLogger new ]
]

{ #category : 'accessing' }
RsRedisSubscriptionManager class >> logger: anLogger [
	^logger := anLogger
]

{ #category : 'class initialization' }
RsRedisSubscriptionManager class >> refreshChannels [
	RsRedisPubsubChannel initialize
]

{ #category : 'class initialization' }
RsRedisSubscriptionManager class >> refreshChannelsAndStart [
	self refreshChannels.
	self default startUp
]

{ #category : 'class initialization' }
RsRedisSubscriptionManager class >> reset [
	<script>
	self initDefault.
	self refreshChannelsAndStart
]

{ #category : 'system startup' }
RsRedisSubscriptionManager class >> shutDown: quitting [
	quitting ifTrue: [
		self initDefault
	]
]

{ #category : 'system startup' }
RsRedisSubscriptionManager class >> startUp: resuming [

	resuming ifFalse: [ ^ self ].
	3 seconds wait.
	self subscribeChannelsOnStartup
		ifTrue: [ self refreshChannelsAndStart ]
		ifFalse: [ self refreshChannels ]
]

{ #category : 'accessing' }
RsRedisSubscriptionManager class >> subscribeChannelsOnStartup [
	^ subscribeChannelsOnStartup ifNil: [ subscribeChannelsOnStartup := true ]
]

{ #category : 'accessing' }
RsRedisSubscriptionManager class >> subscribeChannelsOnStartup: aBoolean [
	subscribeChannelsOnStartup := aBoolean
]

{ #category : 'accessing' }
RsRedisSubscriptionManager >> channelNames [
	^ RsRedisPubsubChannel subscribingChannelNames
]

{ #category : 'accessing' }
RsRedisSubscriptionManager >> connectionKeeper [
	connectionKeeper ifNil: [ 
		connectionKeeper := self createConnectionKeeper.
	].
	^connectionKeeper
]

{ #category : 'accessing' }
RsRedisSubscriptionManager >> connectionKeepingPriority [
	^Processor userSchedulingPriority
]

{ #category : 'factory' }
RsRedisSubscriptionManager >> createConnectionKeeper [
	| keeper |
	
	self isRunning ifTrue: [^self].
	
	keeper := [[self loopPublishPing] ensure: [self stopPublishPing]] newProcess.
	keeper priority: self connectionKeepingPriority.
	keeper name: self className, '-ConnectionKeeper'.
	^ keeper
	

]

{ #category : 'defaults' }
RsRedisSubscriptionManager >> defaultIntervalSeconds [
	^ 33
]

{ #category : 'dispatching' }
RsRedisSubscriptionManager >> dispatchPublishedMessage: aMessage [
	| channel payload |
	aMessage isNormal ifFalse: [ ^self ].
	payload := aMessage payload.
	channel := RsRedisPubsubChannel named: aMessage channel asSymbol.
	channel ifNil: [ ^self ].
	channel rawHandlePublished: payload
	
]

{ #category : 'private' }
RsRedisSubscriptionManager >> evaluateOnceSubscriberNotRestored [

	self onSubscriberNotRestored ifNil: [ ^ self ].
	self onSubscriberNotRestored value.
	self onSubscriberNotRestored: nil
]

{ #category : 'accessing' }
RsRedisSubscriptionManager >> intervalSeconds [
	intervalSeconds ifNil: [ intervalSeconds := self defaultIntervalSeconds ].
	^intervalSeconds
]

{ #category : 'accessing' }
RsRedisSubscriptionManager >> intervalSeconds: anInteger [
	intervalSeconds := anInteger
]

{ #category : 'starting/stopping' }
RsRedisSubscriptionManager >> isRunning [
	connectionKeeper ifNil: [ ^ false ].
	^ (connectionKeeper isTerminating or: [ 
		   connectionKeeper isTerminated or: [ connectionKeeper isSuspended ] ])
		  not
]

{ #category : 'logging' }
RsRedisSubscriptionManager >> logger [
	^self class logger
]

{ #category : 'keeping-connection' }
RsRedisSubscriptionManager >> loopPublishPing [

	[ connectionKeeper notNil ] whileTrue: [ 
		[ 
		self publishPing.
		(Delay forSeconds: self intervalSeconds) wait ] ifCurtailed: [ 
			self stopPublishPing ] ]
]

{ #category : 'accessing' }
RsRedisSubscriptionManager >> maxSubscriberRestorationRetries [
	^ maxSubscriberRestorationRetries ifNil: [ maxSubscriberRestorationRetries := 3 ]
]

{ #category : 'accessing' }
RsRedisSubscriptionManager >> maxSubscriberRestorationRetries: anObject [

	maxSubscriberRestorationRetries := anObject
]

{ #category : 'accessing' }
RsRedisSubscriptionManager >> onSubscriberNotRestored [

	^ onSubscriberNotRestored
]

{ #category : 'accessing' }
RsRedisSubscriptionManager >> onSubscriberNotRestored: aBlock [

	onSubscriberNotRestored := aBlock
]

{ #category : 'factory' }
RsRedisSubscriptionManager >> prepareSubscriber [
	| stick |
	stick := RsRediStick targetUrl: self targetUrl.
	subscriber := stick.
	stick endpoint settings receivingProcessPriority:
		Processor highIOPriority.
	stick onError: [ :ex | self restoreSubscriber: stick ].
	stick connect
]

{ #category : 'pinging' }
RsRedisSubscriptionManager >> publishPing [
	RsRedisPubsubChannel ping publishPing
]

{ #category : 'releasing' }
RsRedisSubscriptionManager >> releaseSubscriber [
	self subscriber ifNotNil: [ :stick | 
		stick destroy.
		self subscriber: nil ]
]

{ #category : 'factory' }
RsRedisSubscriptionManager >> restoreSubscriber: oldSubscriber [
	| oneShotStick subscribed retryMax |
	oldSubscriber destroy.
	subscribed := false.
	retryMax := self maxSubscriberRestorationRetries.
	[ subscribed not and: [ retryMax > 0 ] ] whileTrue: [
		(Delay forSeconds: self restoreSubscriberWaitSeconds) wait.
		oneShotStick := RsRediStick targetUrl: self targetUrl.
		oneShotStick onConnected: [ :stick |
			stick destroy.
			self restoreSubscriptions.
			subscribed := true ].
		oneShotStick connect.
		retryMax := retryMax - 1 ].
	self logger info: '-Subscriber restoration result-' , {subscribed. retryMax } asString.
	subscribed ifFalse: [ self evaluateOnceSubscriberNotRestored ]
]

{ #category : 'accessing' }
RsRedisSubscriptionManager >> restoreSubscriberWaitSeconds [
	^ (self intervalSeconds // 4) max: 3
]

{ #category : 'factory' }
RsRedisSubscriptionManager >> restoreSubscriptions [

	subscriber ifNotNil: [ subscriber destroy ].
	self prepareSubscriber.
	self subscribeChannels
]

{ #category : 'actions' }
RsRedisSubscriptionManager >> shutDown [
	[ self isRunning ifFalse: [ ^ self ].
	self stop.
	self unsubscribeChannels.
	2 seconds wait.
	self releaseSubscriber ]
		on: Error
		do: [ :ex | self logger error: ex ]
]

{ #category : 'starting/stopping' }
RsRedisSubscriptionManager >> start [
	self isRunning ifTrue: [ ^self ].
	self startPublishPing
]

{ #category : 'keeping-connection' }
RsRedisSubscriptionManager >> startPublishPing [
	connectionKeeper := self createConnectionKeeper.
	connectionKeeper resume
]

{ #category : 'actions' }
RsRedisSubscriptionManager >> startUp [
	[ 2 seconds wait.
	[ self subscribeChannels; start ]
		on: SkError
		do: [ :ex | ex inspect ] ] fork
]

{ #category : 'starting/stopping' }
RsRedisSubscriptionManager >> stop [
	self stopPublishPing
]

{ #category : 'keeping-connection' }
RsRedisSubscriptionManager >> stopPublishPing [
	connectionKeeper ifNotNil: [ 
		connectionKeeper terminate.
		connectionKeeper := nil
	]
]

{ #category : 'subscribing' }
RsRedisSubscriptionManager >> subscribeChannels [
	self subscribeChannels: self channelNames
]

{ #category : 'subscribing' }
RsRedisSubscriptionManager >> subscribeChannels: channelNames [
	self subscriber endpoint subscribe: channelNames callback: [ :msg | self dispatchPublishedMessage: msg ]
]

{ #category : 'accessing' }
RsRedisSubscriptionManager >> subscriber [
	subscriber ifNil: [ self prepareSubscriber ].
	^ subscriber
]

{ #category : 'accessing' }
RsRedisSubscriptionManager >> subscriber: aRediStick [
	subscriber := aRediStick
]

{ #category : 'accessing' }
RsRedisSubscriptionManager >> targetUrl [
	^ targetUrl ifNil: [ targetUrl := 'sync://localhost:6379' ].
]

{ #category : 'accessing' }
RsRedisSubscriptionManager >> targetUrl: aString [
	targetUrl := aString
]

{ #category : 'subscribing' }
RsRedisSubscriptionManager >> unsubscribeChannels [
	self unsubscribeChannels: self channelNames
]

{ #category : 'subscribing' }
RsRedisSubscriptionManager >> unsubscribeChannels: channelNames [
	self subscriber endpoint unsubscribe: channelNames
]
