"
I am the abstract superclass of option objects for Redis commands that can set a key's expiration (e.g. SET, GETEX).

Responsibility:
- Provide readable messages for the common expiration options instead of raw tokens:
  #expireIn: (EX), #expireInMilliseconds: (PX), #expireAt: (EXAT), #expireAtMilliseconds: (PXAT)
- Hold the expiration as semantic state (mode + value); the last expiration message sent wins
- Convert a DateAndTime to unix seconds/milliseconds for EXAT/PXAT (integers are passed through)
- Build the expiration tokens in #expirationArgs; subclasses add their command-specific modes (e.g. KEEPTTL, PERSIST) by overriding #expirationArgs and falling back to super; an unknown mode signals RsError invalidArguments
- Subclasses answer their Redis command name in #commandName so error messages keep the command context

Option combinations are not validated; Redis reports invalid ones.

Collaborators:
- RsSetOptions, RsGetExOptions: concrete subclasses that build the full argument list in #asArray
"
Class {
	#name : 'RsExpirationOptions',
	#superclass : 'Object',
	#instVars : [
		'expirationMode',
		'expirationValue'
	],
	#category : 'RediStick-Core',
	#package : 'RediStick-Core'
}

{ #category : 'accessing' }
RsExpirationOptions >> commandName [
	"Answer the Redis command name these options belong to, used in error messages"

	^ self subclassResponsibility
]

{ #category : 'private' }
RsExpirationOptions >> expirationArgs [
	self expirationMode ifNil: [ ^ #(  ) ].
	self expirationMode = #expireIn ifTrue: [ ^ { 'EX'. self expirationValue } ].
	self expirationMode = #expireInMilliseconds ifTrue: [ ^ { 'PX'. self expirationValue } ].
	self expirationMode = #expireAt ifTrue: [
		^ { 'EXAT'. (self unixSecondsFrom: self expirationValue) } ].
	self expirationMode = #expireAtMilliseconds ifTrue: [
		^ { 'PXAT'. (self unixMillisecondsFrom: self expirationValue) } ].
	^ self signalInvalidExpirationMode
]

{ #category : 'accessing' }
RsExpirationOptions >> expirationMode [
	^ expirationMode
]

{ #category : 'private' }
RsExpirationOptions >> expirationMode: aSymbol value: anObject [
	expirationMode := aSymbol.
	expirationValue := anObject
]

{ #category : 'accessing' }
RsExpirationOptions >> expirationValue [
	^ expirationValue
]

{ #category : 'actions' }
RsExpirationOptions >> expireAt: aDateAndTimeOrUnixSeconds [
	self expirationMode: #expireAt value: aDateAndTimeOrUnixSeconds
]

{ #category : 'actions' }
RsExpirationOptions >> expireAtMilliseconds: aDateAndTimeOrUnixMilliseconds [
	self expirationMode: #expireAtMilliseconds value: aDateAndTimeOrUnixMilliseconds
]

{ #category : 'actions' }
RsExpirationOptions >> expireIn: seconds [
	self expirationMode: #expireIn value: seconds
]

{ #category : 'actions' }
RsExpirationOptions >> expireInMilliseconds: milliseconds [
	self expirationMode: #expireInMilliseconds value: milliseconds
]

{ #category : 'private' }
RsExpirationOptions >> signalInvalidExpirationMode [
	^ RsError invalidArguments signal:
		  'Unknown ' , self commandName , ' expiration: ' , self expirationMode printString
]

{ #category : 'private' }
RsExpirationOptions >> unixMillisecondsFrom: aDateAndTimeOrInteger [
	"DateAndTime subtraction is offset-independent, so no UTC normalization is needed.
	#asUnixTime is not used here because it truncates to whole seconds."

	aDateAndTimeOrInteger isInteger ifTrue: [ ^ aDateAndTimeOrInteger ].
	^ (aDateAndTimeOrInteger - DateAndTime unixEpoch) asMilliSeconds
]

{ #category : 'private' }
RsExpirationOptions >> unixSecondsFrom: aDateAndTimeOrInteger [
	aDateAndTimeOrInteger isInteger ifTrue: [ ^ aDateAndTimeOrInteger ].
	^ aDateAndTimeOrInteger asUnixTime
]
