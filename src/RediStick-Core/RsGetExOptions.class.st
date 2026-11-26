"
I hold the optional arguments of the Redis GETEX command.

Responsibility:
- Provide readable messages for the GETEX expiration options instead of raw tokens:
  #expireIn: (EX), #expireInMilliseconds: (PX), #expireAt: (EXAT), #expireAtMilliseconds: (PXAT), #persist (PERSIST)
- Build the GETEX option tokens in #asArray

The common expiration options are inherited from RsExpirationOptions; #persist is GETEX-specific.
The last expiration message sent wins. Option combinations are not validated; Redis reports invalid ones.

Collaborators:
- RsRedisEndpoint: builds me in #getEx:using: and sends my #asArray in #getEx:options:

Example:
	endpoint getEx: 'a' using: [ :opts | opts expireIn: 60 ]
"
Class {
	#name : 'RsGetExOptions',
	#superclass : 'RsExpirationOptions',
	#category : 'RediStick-Core',
	#package : 'RediStick-Core'
}

{ #category : 'converting' }
RsGetExOptions >> asArray [
	^ self expirationArgs asArray
]

{ #category : 'private' }
RsGetExOptions >> customExpirationArgs [
	self expirationMode = #persist ifTrue: [ ^ #( 'PERSIST' ) ].
	^ super customExpirationArgs
]

{ #category : 'actions' }
RsGetExOptions >> persist [
	self expirationMode: #persist value: nil
]
