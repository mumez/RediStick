"
I represent the reply of the Redis FUNCTION STATS command.

Responsibility:
- Hold the currently running script info (nil if none) and per-engine library/function counts.
- Parse raw RESP data returned from Redis FUNCTION STATS command.

Collaborators:
- RsRedisEndpoint: Instantiates me during #functionStats.
"
Class {
	#name : 'RsFunctionStats',
	#superclass : 'Object',
	#instVars : [
		'runningScript',
		'engines'
	],
	#category : 'RediStick-Function',
	#package : 'RediStick-Function'
}

{ #category : 'instance creation' }
RsFunctionStats class >> fromArrayOrDictionary: aCollectionOrDict [
	| dict |
	aCollectionOrDict isDictionary ifTrue: [ ^ self fromDictionary: aCollectionOrDict ].
	dict := Dictionary new.
	1 to: aCollectionOrDict size by: 2 do: [ :i |
		dict at: (aCollectionOrDict at: i) put: (aCollectionOrDict at: i + 1) ].
	^ self fromDictionary: dict
]

{ #category : 'instance creation' }
RsFunctionStats class >> fromDictionary: aDictionary [
	| stats |
	stats := self new.
	stats runningScript: (aDictionary at: 'running_script' ifAbsent: [ nil ]).
	stats engines: (self enginesFromArrayOrDictionary: (aDictionary at: 'engines' ifAbsent: [ #() ])).
	^ stats
]

{ #category : 'private' }
RsFunctionStats class >> enginesFromArrayOrDictionary: aCollectionOrDict [
	| dict result |
	dict := aCollectionOrDict isDictionary
		ifTrue: [ aCollectionOrDict ]
		ifFalse: [
			| d |
			d := Dictionary new.
			1 to: aCollectionOrDict size by: 2 do: [ :i |
				d at: (aCollectionOrDict at: i) put: (aCollectionOrDict at: i + 1) ].
			d ].
	result := Dictionary new.
	dict keysAndValuesDo: [ :engineName :engineInfo |
		result at: engineName put: (self engineInfoFromArrayOrDictionary: engineInfo) ].
	^ result
]

{ #category : 'private' }
RsFunctionStats class >> engineInfoFromArrayOrDictionary: aCollectionOrDict [
	| d |
	aCollectionOrDict isDictionary ifTrue: [ ^ aCollectionOrDict ].
	d := Dictionary new.
	1 to: aCollectionOrDict size by: 2 do: [ :i |
		d at: (aCollectionOrDict at: i) put: (aCollectionOrDict at: i + 1) ].
	^ d
]

{ #category : 'accessing' }
RsFunctionStats >> engines [
	^ engines ifNil: [ Dictionary new ]
]

{ #category : 'accessing' }
RsFunctionStats >> engines: anObject [
	engines := anObject
]

{ #category : 'accessing' }
RsFunctionStats >> runningScript [
	^ runningScript
]

{ #category : 'accessing' }
RsFunctionStats >> runningScript: anObject [
	runningScript := anObject
]
