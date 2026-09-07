"
I represent the cursor position for a TS.READ command: an explicit timestamp, or one of the '-' (earliest) / '+' (latest) / '$' (newest) sentinels.

Responsibility:
- I hold the cursor value (timestamp or sentinel) for TS.READ, normalizing timestamps on construction.
- I render myself as the argument value TS.READ expects, validating on that conversion.

Collaborators:
- RsRedisEndpoint: builds a TS.READ command by asking me for #asArgumentValue.

Public API and Key Messages:
- #earliest / #start (class or instance side) - positions the cursor at the earliest sample ('-' sentinel).
- #latest / #end (class or instance side) - positions the cursor at the latest sample, inclusive ('+' sentinel).
- #newest (class or instance side) - positions the cursor to receive only samples added after the call ('$' sentinel).
- #timestamp: (class or instance side) - positions the cursor at an explicit timestamp, normalized immediately.
- #asArgumentValue - answers the TS.READ cursor argument.
- #validate - checks the cursor is well-formed; not run at construction, only when #asArgumentValue converts the cursor for sending. An unset (nil) value, a negative timestamp, or any other non-integer, non-sentinel value raises RsError at that point, not at #timestamp:.
"
Class {
	#name : 'RsTsReadCursor',
	#superclass : 'Object',
	#instVars : [
		'value'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'instance creation' }
RsTsReadCursor class >> earliest [
	^ self new earliest
]

{ #category : 'instance creation' }
RsTsReadCursor class >> end [
	^ self latest 
]

{ #category : 'instance creation' }
RsTsReadCursor class >> latest [
	^ self new latest
]

{ #category : 'instance creation' }
RsTsReadCursor class >> newest [
	^ self new newest
]

{ #category : 'instance creation' }
RsTsReadCursor class >> start [
	^ self earliest 
]

{ #category : 'instance creation' }
RsTsReadCursor class >> timestamp: aDateAndTimeOrInteger [
	^ self new timestamp: aDateAndTimeOrInteger; yourself
]

{ #category : 'converting' }
RsTsReadCursor >> asArgumentValue [
	self validate.
	^ self value
]

{ #category : 'accessing' }
RsTsReadCursor >> earliest [
	self value: '-'
]

{ #category : 'accessing' }
RsTsReadCursor >> end [
	self latest
]

{ #category : 'accessing' }
RsTsReadCursor >> latest [
	self value: '+'
]

{ #category : 'accessing' }
RsTsReadCursor >> newest [
	self value: '$'
]

{ #category : 'accessing' }
RsTsReadCursor >> start [
	self earliest
]

{ #category : 'accessing' }
RsTsReadCursor >> timestamp: dateAndTimeOrInteger [
	| normalizedInteger |
	normalizedInteger :=  dateAndTimeOrInteger asRediStickUnixTimestampMillis.
	self value: normalizedInteger
]

{ #category : 'validation' }
RsTsReadCursor >> validate [
	"Runs on #asArgumentValue (send-time), not on construction, so a cursor can be freely reassigned before it's sent."

	self value isNil ifTrue: [
		RsError invalidArguments signal: 'Cursor value is not set' ].
	(self value isInteger and: [ self value < 0 ]) ifTrue: [
		RsError invalidArguments signal: 'Minus timestamp value is not allowed ' ].
	(self value isString and: [ (#('-' '+' '$') includes: self value) not ]) ifTrue: [
		RsError invalidArguments signal: 'Cursor value must be an integer timestamp or one of ''-'', ''+'', ''$''' ]
]

{ #category : 'accessing' }
RsTsReadCursor >> value [
	^ value
]

{ #category : 'accessing' }
RsTsReadCursor >> value: anObject [

	value := anObject
]
