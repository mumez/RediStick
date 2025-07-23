Class {
	#name : 'RsGenericError',
	#superclass : 'RsError',
	#instVars : [
		'errorPrefix'
	],
	#category : 'RediStick-Core',
	#package : 'RediStick-Core'
}

{ #category : 'instance creation' }
RsGenericError class >> errorMessage: errorMessage [
	^self new initByErrorMessage: errorMessage
]

{ #category : 'accessing' }
RsGenericError >> errorPrefix [
	^errorPrefix
]

{ #category : 'initialize-release' }
RsGenericError >> initByErrorMessage: aSingleLineOfErrorMessage [
	self otherInfo at: 'message' put: aSingleLineOfErrorMessage.
	self messageText: aSingleLineOfErrorMessage.
	errorPrefix := aSingleLineOfErrorMessage asString readStream upTo: Character space.

]

{ #category : 'testing' }
RsGenericError >> isNoAuth [
	^ self errorPrefix = 'NOAUTH'
]
