"
I hold options for the Redis FUNCTION LIST command.

Responsibility:
- Configure optional LIBRARYNAME pattern filtering and WITHCODE payload flag.
- Convert configured options to an Array of command arguments.

Collaborators:
- RsRedisEndpoint: Uses my instances in #functionListUsing:
"
Class {
	#name : 'RsFunctionListOptions',
	#superclass : 'Object',
	#instVars : [
		'libraryName',
		'withCode'
	],
	#category : 'RediStick-Function',
	#package : 'RediStick-Function'
}

{ #category : 'converting' }
RsFunctionListOptions >> asArray [
	| args |
	args := OrderedCollection new.
	self libraryName ifNotNil: [
		args add: 'LIBRARYNAME'.
		args add: self libraryName ].
	self withCode ifTrue: [
		args add: 'WITHCODE' ].
	^ args asArray
]

{ #category : 'initialization' }
RsFunctionListOptions >> initialize [
	super initialize.
	withCode := false
]

{ #category : 'accessing' }
RsFunctionListOptions >> libraryName [
	^ libraryName
]

{ #category : 'accessing' }
RsFunctionListOptions >> libraryName: aString [
	libraryName := aString
]

{ #category : 'accessing' }
RsFunctionListOptions >> withCode [
	^ withCode ifNil: [ false ]
]

{ #category : 'accessing' }
RsFunctionListOptions >> withCode: aBoolean [
	withCode := aBoolean
]
