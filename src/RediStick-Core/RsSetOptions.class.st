"
I hold the optional arguments of the Redis SET command.

Responsibility:
- Provide readable messages for the SET options instead of raw tokens:
  - Condition: #ifNotExists (NX), #ifAlreadyExists (XX), #ifEqual: (IFEQ), #ifNotEqual: (IFNE), #ifDigestEqual: (IFDEQ), #ifDigestNotEqual: (IFDNE)
  - #get (GET) to return the old value
  - Expiration: #expireIn: (EX), #expireInMilliseconds: (PX), #expireAt: (EXAT), #expireAtMilliseconds: (PXAT), #keepTtl (KEEPTTL)
- Hold the options as semantic state (condition mode + value, expiration mode + value) and build the SET command tokens in #asArray

Within each group (condition / expiration), the last message sent wins. Option combinations are not validated; Redis reports invalid ones.

Collaborators:
- RsRedisEndpoint: builds me in #set:value:using: and sends my #asArray in #set:value:options:

Example:
	endpoint set: 'a' value: 123 using: [ :opts | opts ifNotExists; get; expireIn: 1000 ]
"
Class {
	#name : 'RsSetOptions',
	#superclass : 'Object',
	#instVars : [
		'conditionMode',
		'conditionValue',
		'shouldGet',
		'expirationMode',
		'expirationValue'
	],
	#category : 'RediStick-Core',
	#package : 'RediStick-Core'
}

{ #category : 'converting' }
RsSetOptions >> asArray [
	| args |
	args := OrderedCollection new.
	args addAll: self conditionArgs.
	self shouldGet ifTrue: [ args add: 'GET' ].
	args addAll: self expirationArgs.
	^ args asArray
]

{ #category : 'private' }
RsSetOptions >> conditionArgs [
	self conditionMode ifNil: [ ^ #(  ) ].
	self conditionMode = #ifNotExists ifTrue: [ ^ #( 'NX' ) ].
	self conditionMode = #ifAlreadyExists ifTrue: [ ^ #( 'XX' ) ].
	self conditionMode = #ifEqual ifTrue: [ ^ { 'IFEQ'. self conditionValue } ].
	self conditionMode = #ifNotEqual ifTrue: [ ^ { 'IFNE'. self conditionValue } ].
	self conditionMode = #ifDigestEqual ifTrue: [ ^ { 'IFDEQ'. self conditionValue } ].
	self conditionMode = #ifDigestNotEqual ifTrue: [ ^ { 'IFDNE'. self conditionValue } ].
	^ RsError signal: 'Unknown SET condition: ' , self conditionMode printString
]

{ #category : 'accessing' }
RsSetOptions >> conditionMode [
	^ conditionMode
]

{ #category : 'private' }
RsSetOptions >> conditionMode: aSymbol value: anObject [
	conditionMode := aSymbol.
	conditionValue := anObject
]

{ #category : 'accessing' }
RsSetOptions >> conditionValue [
	^ conditionValue
]

{ #category : 'private' }
RsSetOptions >> expirationArgs [
	self expirationMode ifNil: [ ^ #(  ) ].
	self expirationMode = #expireIn ifTrue: [ ^ { 'EX'. self expirationValue } ].
	self expirationMode = #expireInMilliseconds ifTrue: [ ^ { 'PX'. self expirationValue } ].
	self expirationMode = #expireAt ifTrue: [
		^ { 'EXAT'. (self unixSecondsFrom: self expirationValue) } ].
	self expirationMode = #expireAtMilliseconds ifTrue: [
		^ { 'PXAT'. (self unixMillisecondsFrom: self expirationValue) } ].
	self expirationMode = #keepTtl ifTrue: [ ^ #( 'KEEPTTL' ) ].
	^ RsError signal: 'Unknown SET expiration: ' , self expirationMode printString
]

{ #category : 'accessing' }
RsSetOptions >> expirationMode [
	^ expirationMode
]

{ #category : 'private' }
RsSetOptions >> expirationMode: aSymbol value: anObject [
	expirationMode := aSymbol.
	expirationValue := anObject
]

{ #category : 'accessing' }
RsSetOptions >> expirationValue [
	^ expirationValue
]

{ #category : 'actions' }
RsSetOptions >> expireAt: aDateAndTimeOrUnixSeconds [
	self expirationMode: #expireAt value: aDateAndTimeOrUnixSeconds
]

{ #category : 'actions' }
RsSetOptions >> expireAtMilliseconds: aDateAndTimeOrUnixMilliseconds [
	self expirationMode: #expireAtMilliseconds value: aDateAndTimeOrUnixMilliseconds
]

{ #category : 'actions' }
RsSetOptions >> expireIn: seconds [
	self expirationMode: #expireIn value: seconds
]

{ #category : 'actions' }
RsSetOptions >> expireInMilliseconds: milliseconds [
	self expirationMode: #expireInMilliseconds value: milliseconds
]

{ #category : 'actions' }
RsSetOptions >> get [
	self shouldGet: true
]

{ #category : 'actions' }
RsSetOptions >> ifAlreadyExists [
	self conditionMode: #ifAlreadyExists value: nil
]

{ #category : 'actions' }
RsSetOptions >> ifDigestEqual: aDigestString [
	self conditionMode: #ifDigestEqual value: aDigestString
]

{ #category : 'actions' }
RsSetOptions >> ifDigestNotEqual: aDigestString [
	self conditionMode: #ifDigestNotEqual value: aDigestString
]

{ #category : 'actions' }
RsSetOptions >> ifEqual: aValue [
	self conditionMode: #ifEqual value: aValue
]

{ #category : 'actions' }
RsSetOptions >> ifNotEqual: aValue [
	self conditionMode: #ifNotEqual value: aValue
]

{ #category : 'actions' }
RsSetOptions >> ifNotExists [
	self conditionMode: #ifNotExists value: nil
]

{ #category : 'actions' }
RsSetOptions >> keepTtl [
	self expirationMode: #keepTtl value: nil
]

{ #category : 'testing' }
RsSetOptions >> shouldGet [
	^ shouldGet ifNil: [ false ]
]

{ #category : 'accessing' }
RsSetOptions >> shouldGet: aBoolean [
	shouldGet := aBoolean
]

{ #category : 'private' }
RsSetOptions >> unixMillisecondsFrom: aDateAndTimeOrInteger [
	"DateAndTime subtraction is offset-independent, so no UTC normalization is needed.
	#asUnixTime is not used here because it truncates to whole seconds."

	aDateAndTimeOrInteger isInteger ifTrue: [ ^ aDateAndTimeOrInteger ].
	^ (aDateAndTimeOrInteger - DateAndTime unixEpoch) asMilliSeconds
]

{ #category : 'private' }
RsSetOptions >> unixSecondsFrom: aDateAndTimeOrInteger [
	aDateAndTimeOrInteger isInteger ifTrue: [ ^ aDateAndTimeOrInteger ].
	^ aDateAndTimeOrInteger asUnixTime
]
