Class {
	#name : 'RsStreamPendingMessagesOptions',
	#superclass : 'Object',
	#instVars : [
		'minIdleMilliseconds',
		'start',
		'end',
		'count',
		'consumer'
	],
	#category : 'RediStick-Stream',
	#package : 'RediStick-Stream'
}

{ #category : 'converting' }
RsStreamPendingMessagesOptions >> asArray [
	| opts |
	opts := {} asOrderedCollection.
	self minIdleMilliseconds ifNotNil: [ :op | opts addAll: {'IDLE'. op} ].
	opts add: self start.
	opts add: self end.
	opts add: self count.
	self consumer ifNotNil: [ :con | opts add: con ].
	^ opts asArray
]

{ #category : 'accessing' }
RsStreamPendingMessagesOptions >> consumer [

	^ consumer
]

{ #category : 'accessing' }
RsStreamPendingMessagesOptions >> consumer: anObject [

	consumer := anObject
]

{ #category : 'accessing' }
RsStreamPendingMessagesOptions >> count [

	^ count
]

{ #category : 'accessing' }
RsStreamPendingMessagesOptions >> count: anObject [

	count := anObject
]

{ #category : 'accessing' }
RsStreamPendingMessagesOptions >> end [

	^ end
]

{ #category : 'accessing' }
RsStreamPendingMessagesOptions >> end: anObject [

	end := anObject
]

{ #category : 'accessing' }
RsStreamPendingMessagesOptions >> minIdleMilliseconds [

	^ minIdleMilliseconds
]

{ #category : 'accessing' }
RsStreamPendingMessagesOptions >> minIdleMilliseconds: anObject [

	minIdleMilliseconds := anObject
]

{ #category : 'accessing' }
RsStreamPendingMessagesOptions >> start [

	^ start
]

{ #category : 'accessing' }
RsStreamPendingMessagesOptions >> start: anObject [

	start := anObject
]
