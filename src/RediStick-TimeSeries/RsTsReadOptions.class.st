"
I represent the optional BLOCK and MAX_COUNT parameters for a TS.READ command.

Responsibility:
- I hold the optional blocking (milliseconds/minCount) and MAX_COUNT settings for TS.READ.
- I render myself as the ordered array of command-argument tokens TS.READ expects.

Collaborators:
- RsRedisEndpoint: builds a TS.READ command by asking me for #asArray and appending it after the key/cursor.

Public API and Key Messages:
- #block:minCount: - sets BLOCK milliseconds and minCount together (both are required by Redis, or neither).
- #maxCount: - sets MAX_COUNT.
- #asArray - answers the command tokens in Redis's required order (BLOCK ... before MAX_COUNT ...), omitting any unset option. Raises RsError if only one of BLOCK milliseconds/minCount is set, or if minCount exceeds MAX_COUNT when both are set.
"
Class {
	#name : 'RsTsReadOptions',
	#superclass : 'Object',
	#instVars : [
		'blockMilliseconds',
		'blockMinCount',
		'maxCount'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'converting' }
RsTsReadOptions >> asArray [
	| opts |
	opts := OrderedCollection new.
	self blockMilliseconds isNil == self blockMinCount isNil ifFalse: [
		RsError invalidArguments signal: 'BLOCK requires both milliseconds and minCount, or neither' ].
	(self blockMinCount notNil and: [ self maxCount notNil and: [ self blockMinCount > self maxCount ] ])
		ifTrue: [
			RsError invalidArguments signal: 'BLOCK minCount must not be greater than MAX_COUNT' ].
	(self blockMilliseconds notNil and: [ self blockMinCount notNil ]) ifTrue: [
		opts addAll: { 'BLOCK'. self blockMilliseconds. self blockMinCount } ].
	self maxCount ifNotNil: [ :c | opts addAll: { 'MAX_COUNT'. c } ].
	^ opts asArray
]

{ #category : 'accessing' }
RsTsReadOptions >> block: milliseconds minCount: aMinCount [
	blockMilliseconds := milliseconds.
	blockMinCount := aMinCount
]

{ #category : 'accessing' }
RsTsReadOptions >> blockMilliseconds [
	^ blockMilliseconds
]

{ #category : 'accessing' }
RsTsReadOptions >> blockMinCount [
	^ blockMinCount
]

{ #category : 'accessing' }
RsTsReadOptions >> maxCount [
	^ maxCount
]

{ #category : 'accessing' }
RsTsReadOptions >> maxCount: anInteger [
	maxCount := anInteger
]
