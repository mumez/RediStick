Class {
	#name : 'RsStreamBasePoller',
	#superclass : 'Object',
	#instVars : [
		'shouldKeepPolling',
		'currentId',
		'pollingPriority',
		'logger',
		'onReceive',
		'onPollFail',
		'onReceiveFail',
		'pollingProcess'
	],
	#category : 'RediStick-Stream-Objects',
	#package : 'RediStick-Stream-Objects'
}

{ #category : 'utilities' }
RsStreamBasePoller class >> killAll [
	<script>
	self allSubInstances do: [ :e | e kill ]
]

{ #category : 'private' }
RsStreamBasePoller >> basicPoll [
	self subclassResponsibility 
]

{ #category : 'accessing' }
RsStreamBasePoller >> currentId [

	^ currentId
]

{ #category : 'accessing' }
RsStreamBasePoller >> currentId: anObject [

	currentId := anObject
]

{ #category : 'defaults' }
RsStreamBasePoller >> defaultLogger [
	^ SkLocalLogger new
]

{ #category : 'defaults' }
RsStreamBasePoller >> defaultOnRecaiveFailBlock [
	^ [ :ex :each |
	  self logger error: {
			  #ReceiveNotAccepted.
			  ex description.
			  each asString } ]
]

{ #category : 'defaults' }
RsStreamBasePoller >> defaultPollingPriority [
	^ Processor userBackgroundPriority
]

{ #category : 'handling' }
RsStreamBasePoller >> handleReceived: receivedEntry [
	self onReceive value: receivedEntry
]

{ #category : 'testing' }
RsStreamBasePoller >> isConnected [
	^ self stick endpoint socketIsConnected
]

{ #category : 'actions' }
RsStreamBasePoller >> keepPolling [
	[ self shouldKeepPolling ] whileTrue: [ self poll ]
]

{ #category : 'actions' }
RsStreamBasePoller >> kill [
	pollingProcess ifNil: [ ^self ].
	pollingProcess terminate.
	shouldKeepPolling := false
]

{ #category : 'accessing' }
RsStreamBasePoller >> logger [

	^ logger ifNil: [ logger := self defaultLogger ]
]

{ #category : 'accessing' }
RsStreamBasePoller >> logger: anObject [

	logger := anObject
]

{ #category : 'callback' }
RsStreamBasePoller >> onPollFail [

	^ onPollFail ifNil: [ onPollFail := [:ex | self stop. ex pass] ]
]

{ #category : 'callback' }
RsStreamBasePoller >> onPollFail: anObject [

	onPollFail := anObject
]

{ #category : 'callback' }
RsStreamBasePoller >> onReceive [

	^ onReceive ifNil: [ onReceive := [ :received |  ] ]
]

{ #category : 'callback' }
RsStreamBasePoller >> onReceive: anObject [

	onReceive := anObject
]

{ #category : 'callback' }
RsStreamBasePoller >> onReceiveFail [
	^ onReceiveFail ifNil: [
		  onReceiveFail := self defaultOnRecaiveFailBlock ]
]

{ #category : 'callback' }
RsStreamBasePoller >> onReceiveFail: anObject [

	onReceiveFail := anObject
]

{ #category : 'actions' }
RsStreamBasePoller >> poll [
	| received |
	self isConnected ifFalse: [ ^ self waitFor: 1000; refresh ].
	received := [self basicPoll]
		  on: Error
		  do: [ :ex |
			  self waitFor: 500.
			  self onPollFail value: ex.
			  #(  ) ].
	received do: [ :each |
		| processed |
		processed := true.
		[ self handleReceived: each ]
			on: Error
			do: [ :ex |
				processed := false.
				self onReceiveFail value: ex value: each ].
		processed ifTrue: [ self currentId: each asStreamMessageId ] ]
]

{ #category : 'accessing' }
RsStreamBasePoller >> pollingPriority [
	^ pollingPriority ifNil: [ pollingPriority := self defaultPollingPriority ].
]

{ #category : 'accessing' }
RsStreamBasePoller >> pollingPriority: anInteger [
	pollingPriority := anInteger
]

{ #category : 'accessing' }
RsStreamBasePoller >> readChunkSize [
	^ self settings pollReadChunkSize
]

{ #category : 'accessing' }
RsStreamBasePoller >> readChunkSize: anInteger [
	^ self settings iterationReadChunkSize: anInteger
]

{ #category : 'private' }
RsStreamBasePoller >> refresh [
	self subclassResponsibility 
]

{ #category : 'accessing' }
RsStreamBasePoller >> settings [
	^ self stream settings
]

{ #category : 'accessing' }
RsStreamBasePoller >> shouldKeepPolling [
	^ shouldKeepPolling ifNil: [ shouldKeepPolling := false ]
]

{ #category : 'accessing' }
RsStreamBasePoller >> shouldKeepPolling: aBoolean [
	shouldKeepPolling := aBoolean
]

{ #category : 'actions' }
RsStreamBasePoller >> start [
	self shouldKeepPolling ifTrue: [ ^self ].
	self shouldKeepPolling: true.
	pollingProcess := [self keepPolling] forkAt: self pollingPriority
]

{ #category : 'accessing' }
RsStreamBasePoller >> stick [
	^ self stream stick
]

{ #category : 'actions' }
RsStreamBasePoller >> stop [
	self shouldKeepPolling: false
]

{ #category : 'accessing' }
RsStreamBasePoller >> stream [
	^ self subclassResponsibility 
]

{ #category : 'accessing' }
RsStreamBasePoller >> streamName [
	^ self stream name
]

{ #category : 'private' }
RsStreamBasePoller >> waitFor: milliseconds [
	(Delay forMilliseconds: milliseconds ) wait
]

{ #category : 'accessing' }
RsStreamBasePoller >> waitMilliseconds [
	^ self settings waitMilliseconds
]

{ #category : 'accessing' }
RsStreamBasePoller >> waitMilliseconds: anInteger [
	^ self settings waitMilliseconds: anInteger 
]
