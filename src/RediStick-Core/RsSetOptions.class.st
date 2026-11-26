"
I hold the optional arguments of the Redis SET command.

Responsibility:
- Provide readable messages for the SET options instead of raw tokens:
  - Condition: #ifNotExists (NX), #ifAlreadyExists (XX), #ifEqual: (IFEQ), #ifNotEqual: (IFNE), #ifDigestEqual: (IFDEQ), #ifDigestNotEqual: (IFDNE)
  - #get (GET) to return the old value
  - Expiration: #expireIn: (EX), #expireInMilliseconds: (PX), #expireAt: (EXAT), #expireAtMilliseconds: (PXAT), #keepTtl (KEEPTTL)
- Hold the options as semantic state (condition mode + value, expiration mode + value) and build the SET command tokens in #asArray
- The common expiration options are inherited from RsExpirationOptions; #keepTtl is SET-specific

Within each group (condition / expiration), the last message sent wins. Option combinations are not validated; Redis reports invalid ones.

Collaborators:
- RsRedisEndpoint: builds me in #set:value:using: and sends my #asArray in #set:value:options:

Example:
	endpoint set: 'a' value: 123 using: [ :opts | opts ifNotExists; get; expireIn: 1000 ]
"
Class {
	#name : 'RsSetOptions',
	#superclass : 'RsExpirationOptions',
	#instVars : [
		'conditionMode',
		'conditionValue',
		'shouldGet'
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
	^ RsError invalidArguments signal: 'Unknown SET condition: ' , self conditionMode printString
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

{ #category : 'accessing' }
RsSetOptions >> commandName [
	^ 'SET'
]

{ #category : 'private' }
RsSetOptions >> customExpirationArgs [
	self expirationMode = #keepTtl ifTrue: [ ^ #( 'KEEPTTL' ) ].
	^ super customExpirationArgs
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
