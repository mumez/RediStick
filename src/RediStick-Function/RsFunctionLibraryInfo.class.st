"
I represent details for a Redis function library, as returned by FUNCTION LIST.

Responsibility:
- Hold library name, engine (e.g. 'LUA'), collection of functions (RsFunctionInfo), and library code.
- Parse raw RESP data returned from Redis FUNCTION LIST command.

Collaborators:
- RsFunctionInfo: Represents individual functions inside this library.
- RsRedisEndpoint: Instantiates me during #functionList operations.
"
Class {
	#name : 'RsFunctionLibraryInfo',
	#superclass : 'Object',
	#instVars : [
		'name',
		'engine',
		'functions',
		'code'
	],
	#category : 'RediStick-Function',
	#package : 'RediStick-Function'
}

{ #category : 'instance creation' }
RsFunctionLibraryInfo class >> fromArrayOrDictionary: aCollectionOrDict [
	| dict |
	aCollectionOrDict ifNil: [ ^ nil ].
	aCollectionOrDict isDictionary ifTrue: [ ^ self fromDictionary: aCollectionOrDict ].
	dict := Dictionary new.
	1 to: aCollectionOrDict size by: 2 do: [ :i |
		dict at: (aCollectionOrDict at: i) put: (aCollectionOrDict at: i + 1) ].
	^ self fromDictionary: dict
]

{ #category : 'instance creation' }
RsFunctionLibraryInfo class >> fromDictionary: aDictionary [
	| lib functionsRaw functionsList |
	lib := self new.
	lib name: (aDictionary at: 'library_name' ifAbsent: [ nil ]).
	lib engine: (aDictionary at: 'engine' ifAbsent: [ nil ]).
	lib code: (aDictionary at: 'library_code' ifAbsent: [ nil ]).
	functionsRaw := aDictionary at: 'functions' ifAbsent: [ #() ].
	functionsList := functionsRaw collect: [ :each |
		RsFunctionInfo fromArrayOrDictionary: each ].
	lib functions: functionsList asArray.
	^ lib
]

{ #category : 'accessing' }
RsFunctionLibraryInfo >> code [
	^ code
]

{ #category : 'accessing' }
RsFunctionLibraryInfo >> code: anObject [
	code := anObject
]

{ #category : 'accessing' }
RsFunctionLibraryInfo >> engine [
	^ engine
]

{ #category : 'accessing' }
RsFunctionLibraryInfo >> engine: anObject [
	engine := anObject
]

{ #category : 'accessing' }
RsFunctionLibraryInfo >> functions [
	^ functions ifNil: [ #() ]
]

{ #category : 'accessing' }
RsFunctionLibraryInfo >> functions: anObject [
	functions := anObject
]

{ #category : 'accessing' }
RsFunctionLibraryInfo >> name [
	^ name
]

{ #category : 'accessing' }
RsFunctionLibraryInfo >> name: anObject [
	name := anObject
]

{ #category : 'printing' }
RsFunctionLibraryInfo >> printOn: aStream [
	super printOn: aStream.
	self name ifNotNil: [
		aStream
			nextPut: $(;
			nextPutAll: self name;
			nextPut: $) ]
]
