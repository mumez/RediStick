"
I hold options for the Redis FUNCTION RESTORE command.

Responsibility:
- Configure the optional policy (APPEND/FLUSH/REPLACE) for restoring function libraries.
- Convert configured options to an Array of command arguments.

Collaborators:
- RsRedisEndpoint: Uses my instances in #functionRestore:using:
"
Class {
	#name : 'RsFunctionRestoreOptions',
	#superclass : 'Object',
	#instVars : [
		'policy'
	],
	#category : 'RediStick-Function',
	#package : 'RediStick-Function'
}

{ #category : 'converting' }
RsFunctionRestoreOptions >> asArray [
	| args |
	args := OrderedCollection new.
	self policy ifNotNil: [ args add: self policy ].
	^ args asArray
]

{ #category : 'accessing' }
RsFunctionRestoreOptions >> policy [
	^ policy
]

{ #category : 'accessing' }
RsFunctionRestoreOptions >> policy: aString [
	policy := aString
]
