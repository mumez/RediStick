"
I represent metadata for an individual Redis function within a function library.

Responsibility:
- Hold function name, description, and execution flags (e.g., 'no-writes').
- Provide convenience methods like #isNoWrites.

Collaborators:
- RsFunctionLibraryInfo: Holds a collection of my instances.
"
Class {
	#name : 'RsFunctionInfo',
	#superclass : 'Object',
	#instVars : [
		'name',
		'description',
		'flags'
	],
	#category : 'RediStick-Function',
	#package : 'RediStick-Function'
}

{ #category : 'instance creation' }
RsFunctionInfo class >> fromArrayOrDictionary: aCollectionOrDict [
	| dict |
	aCollectionOrDict ifNil: [ ^ nil ].
	aCollectionOrDict isDictionary ifTrue: [ ^ self fromDictionary: aCollectionOrDict ].
	dict := Dictionary new.
	1 to: aCollectionOrDict size by: 2 do: [ :i |
		dict at: (aCollectionOrDict at: i) put: (aCollectionOrDict at: i + 1) ].
	^ self fromDictionary: dict
]

{ #category : 'instance creation' }
RsFunctionInfo class >> fromDictionary: aDictionary [
	| func |
	func := self new.
	func name: (aDictionary at: 'name' ifAbsent: [ nil ]).
	func description: (aDictionary at: 'description' ifAbsent: [ nil ]).
	func flags: (aDictionary at: 'flags' ifAbsent: [ #() ]) asArray.
	^ func
]

{ #category : 'accessing' }
RsFunctionInfo >> description [
	^ description
]

{ #category : 'accessing' }
RsFunctionInfo >> description: anObject [
	description := anObject
]

{ #category : 'accessing' }
RsFunctionInfo >> flags [
	^ flags ifNil: [ #() ]
]

{ #category : 'accessing' }
RsFunctionInfo >> flags: anObject [
	flags := anObject
]

{ #category : 'testing' }
RsFunctionInfo >> isNoWrites [
	^ self flags includes: 'no-writes'
]

{ #category : 'accessing' }
RsFunctionInfo >> name [
	^ name
]

{ #category : 'accessing' }
RsFunctionInfo >> name: anObject [
	name := anObject
]

{ #category : 'printing' }
RsFunctionInfo >> printOn: aStream [
	super printOn: aStream.
	self name ifNotNil: [
		aStream
			nextPut: $(;
			nextPutAll: self name;
			nextPut: $) ]
]
