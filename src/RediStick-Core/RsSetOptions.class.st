"
I hold the optional arguments of the Redis SET command.

Responsibility:
- Provide readable messages for the SET options instead of raw tokens:
  - Condition: #ifNotExists (NX), #ifAlreadyExists (XX), #ifEqual: (IFEQ), #ifNotEqual: (IFNE), #ifDigestEqual: (IFDEQ), #ifDigestNotEqual: (IFDNE)
  - #get (GET) to return the old value
  - Expiration: #expireIn: (EX), #expireInMilliseconds: (PX), #expireAt: (EXAT), #expireAtMilliseconds: (PXAT), #keepTtl (KEEPTTL)
- Convert the options into SET command arguments (#asArray)

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
		'condition',
		'shouldGet',
		'expiration'
	],
	#category : 'RediStick-Core',
	#package : 'RediStick-Core'
}

{ #category : 'converting' }
RsSetOptions >> asArray [
	| args |
	args := OrderedCollection new.
	self condition ifNotNil: [ :cond | args addAll: cond ].
	self shouldGet ifTrue: [ args add: 'GET' ].
	self expiration ifNotNil: [ :expr | args addAll: expr ].
	^ args asArray
]

{ #category : 'accessing' }
RsSetOptions >> condition [
	^ condition
]

{ #category : 'accessing' }
RsSetOptions >> condition: anArray [
	condition := anArray
]

{ #category : 'accessing' }
RsSetOptions >> expiration [
	^ expiration
]

{ #category : 'accessing' }
RsSetOptions >> expiration: anArray [
	expiration := anArray
]

{ #category : 'actions' }
RsSetOptions >> expireAt: aDateAndTimeOrUnixSeconds [
	self expiration: {
		              'EXAT'.
		              (self unixSecondsFrom: aDateAndTimeOrUnixSeconds) }
]

{ #category : 'actions' }
RsSetOptions >> expireAtMilliseconds: aDateAndTimeOrUnixMilliseconds [
	self expiration: {
		              'PXAT'.
		              (self unixMillisecondsFrom: aDateAndTimeOrUnixMilliseconds) }
]

{ #category : 'actions' }
RsSetOptions >> expireIn: seconds [
	self expiration: {
		              'EX'.
		              seconds }
]

{ #category : 'actions' }
RsSetOptions >> expireInMilliseconds: milliseconds [
	self expiration: {
		              'PX'.
		              milliseconds }
]

{ #category : 'actions' }
RsSetOptions >> get [
	self shouldGet: true
]

{ #category : 'actions' }
RsSetOptions >> ifAlreadyExists [
	self condition: #( 'XX' )
]

{ #category : 'actions' }
RsSetOptions >> ifDigestEqual: aDigestString [
	self condition: {
		             'IFDEQ'.
		             aDigestString }
]

{ #category : 'actions' }
RsSetOptions >> ifDigestNotEqual: aDigestString [
	self condition: {
		             'IFDNE'.
		             aDigestString }
]

{ #category : 'actions' }
RsSetOptions >> ifEqual: aValue [
	self condition: {
		             'IFEQ'.
		             aValue }
]

{ #category : 'actions' }
RsSetOptions >> ifNotEqual: aValue [
	self condition: {
		             'IFNE'.
		             aValue }
]

{ #category : 'actions' }
RsSetOptions >> ifNotExists [
	self condition: #( 'NX' )
]

{ #category : 'actions' }
RsSetOptions >> keepTtl [
	self expiration: #( 'KEEPTTL' )
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
	aDateAndTimeOrInteger isInteger ifTrue: [ ^ aDateAndTimeOrInteger ].
	^ ((aDateAndTimeOrInteger offset: Duration zero) - DateAndTime unixEpoch) asMilliSeconds
]

{ #category : 'private' }
RsSetOptions >> unixSecondsFrom: aDateAndTimeOrInteger [
	aDateAndTimeOrInteger isInteger ifTrue: [ ^ aDateAndTimeOrInteger ].
	^ aDateAndTimeOrInteger asUnixTime
]
