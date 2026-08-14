"
I represent the optional parameters for Redis's VADD command.

Responsibility:
- I build the token array (CAS, NOQUANT|Q8|BIN, EF, SETATTR, M) appended
  after the vector/element in VADD's wire format.
- I hold REDUCE separately via reduceDim, since the caller reads it
  directly rather than through #asArray (it precedes the vector, not
  the options that follow it).

Collaborators:
- RsRedisEndpoint: sends #vAdd:element:vector:using: with an instance of
  me, then reads #reduceDim and #asArray to assemble the VADD command.

Public API and Key Messages:
- #cas - marks the add as check-and-set (adds the CAS token).
- #quantization: - sets #noQuant, #q8, or #bin.
- #ef:, #m:, #setAttr:, #reduceDim: - set the corresponding options.
- #asArray - answers the ordered tokens for CAS/quantization/EF/SETATTR/M.

Internal Representation:
- reduceDim - target dimension for random projection (read by the caller,
  not included in #asArray).
- cas - Boolean; true once #cas has been sent.
- quantization - one of #noQuant, #q8, #bin, or nil.
- ef - exploration factor for the build-time search.
- setAttr - raw JSON String or Smalltalk object attached via SETATTR.
- m - max number of connections per graph node.
"
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

{ #category : 'actions' }
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
