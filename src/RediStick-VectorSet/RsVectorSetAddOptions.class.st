Class {
	#name : 'RsVectorSetAddOptions',
	#superclass : 'Object',
	#instVars : [
		'reduceDim',
		'cas',
		'quantization',
		'ef',
		'setAttr',
		'm'
	],
	#category : 'RediStick-VectorSet',
	#package : 'RediStick-VectorSet'
}

{ #category : 'initialization' }
RsVectorSetAddOptions >> initialize [
	super initialize.
	cas := false
]

{ #category : 'converting' }
RsVectorSetAddOptions >> asArray [
	"Emits tokens placed after the vector/element in VADD's wire format:
	CAS, NOQUANT|Q8|BIN, EF, SETATTR, M. REDUCE precedes the vector and is
	read directly via reduceDim by the endpoint, so it is not included here."
	| opts |
	opts := OrderedCollection new.
	self isCas ifTrue: [ opts add: 'CAS' ].
	self quantization ifNotNil: [ :q | opts add: self quantizationToken ].
	self ef ifNotNil: [ :e | opts addAll: { 'EF'. e } ].
	self setAttr ifNotNil: [ :a | opts addAll: { 'SETATTR'. self setAttrAsJsonString } ].
	self m ifNotNil: [ :numLinks | opts addAll: { 'M'. numLinks } ].
	^ opts asArray
]

{ #category : 'accessing' }
RsVectorSetAddOptions >> cas [
	cas := true
]

{ #category : 'accessing' }
RsVectorSetAddOptions >> ef [
	^ ef
]

{ #category : 'accessing' }
RsVectorSetAddOptions >> ef: anInteger [
	ef := anInteger
]

{ #category : 'testing' }
RsVectorSetAddOptions >> isCas [
	^ cas
]

{ #category : 'accessing' }
RsVectorSetAddOptions >> m [
	^ m
]

{ #category : 'accessing' }
RsVectorSetAddOptions >> m: anInteger [
	m := anInteger
]

{ #category : 'accessing' }
RsVectorSetAddOptions >> quantization [
	^ quantization
]

{ #category : 'accessing' }
RsVectorSetAddOptions >> quantization: aSymbol [
	"One of #noQuant, #q8, #bin, or nil."
	quantization := aSymbol
]

{ #category : 'private' }
RsVectorSetAddOptions >> quantizationToken [
	self quantization == #noQuant ifTrue: [ ^ 'NOQUANT' ].
	self quantization == #q8 ifTrue: [ ^ 'Q8' ].
	self quantization == #bin ifTrue: [ ^ 'BIN' ].
	^ self error: 'Unknown quantization: ', self quantization printString
]

{ #category : 'accessing' }
RsVectorSetAddOptions >> reduceDim [
	^ reduceDim
]

{ #category : 'accessing' }
RsVectorSetAddOptions >> reduceDim: anInteger [
	reduceDim := anInteger
]

{ #category : 'accessing' }
RsVectorSetAddOptions >> setAttr [
	^ setAttr
]

{ #category : 'accessing' }
RsVectorSetAddOptions >> setAttr: aJsonStringOrObject [
	"Accepts a raw JSON String or a Smalltalk object (Dictionary/Array/etc.),
	which is converted to JSON lazily when the options are read."
	setAttr := aJsonStringOrObject
]

{ #category : 'private' }
RsVectorSetAddOptions >> setAttrAsJsonString [
	^ (self setAttr isString or: [ self setAttr isSymbol ])
		ifTrue: [ self setAttr asString ]
		ifFalse: [ NeoJSONWriter toString: self setAttr ]
]
