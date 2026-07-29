Class {
	#name : 'RsTsRange',
	#superclass : 'Object',
	#instVars : [
		'from',
		'to'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'instance creation' }
RsTsRange class >> all [
	^ self from: self start to: self end
]


{ #category : 'instance creation' }
RsTsRange class >> from: aFrom [
	^ self from: aFrom to: self end
]

{ #category : 'instance creation' }
RsTsRange class >> from: aFrom to: aTo [
	^ self new
		setFrom: (self normalizeTimestamp: aFrom)
		to: (self normalizeTimestamp: aTo)
]

{ #category : 'instance creation' }
RsTsRange class >> to: aTo [
	^ self from: self start to: aTo
]

{ #category : 'private' }
RsTsRange class >> normalizeTimestamp: aValue [
	aValue isString ifTrue: [ ^ aValue ].
	^ aValue asRediStickUnixTimestampMillis
]

{ #category : 'constants' }
RsTsRange class >> start [
	^ '-'
]

{ #category : 'constants' }
RsTsRange class >> end [
	^ '~'
]

{ #category : 'constants' }
RsTsRange class >> mid [
	^ '+'
]

{ #category : 'converting' }
RsTsRange >> asArray [
	^ { self from. self to }
]

{ #category : 'accessing' }
RsTsRange >> from [
	^ from
]

{ #category : 'accessing' }
RsTsRange >> to [
	^ to
]

{ #category : 'private' }
RsTsRange >> setFrom: aFrom to: aTo [
	from := aFrom.
	to := aTo
]
