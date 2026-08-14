"
I represent one row of a Redis VSIM reply.

Responsibility:
- I wrap an element name together with its optional similarity score
  (present only when WITHSCORES was requested) and optional attributes
  (present only when WITHATTRIBS was requested).

Collaborators:
- RsRedisEndpoint: builds instances of me from VSIM replies in
  #vSim:queryBy:using:.

Public API and Key Messages:
- #element - the matched element name.
- #score - the similarity score (Float), or nil unless WITHSCORES.
- #attribs - the parsed JSON attributes, or nil unless WITHATTRIBS (or the
  element has no attributes).

Internal Representation:
- element - String.
- score - Float or nil.
- attribs - parsed Smalltalk object (Dictionary/Array/etc.) or nil.
"
Class {
	#name : 'RsVectorSetSimResult',
	#superclass : 'Object',
	#instVars : [
		'element',
		'score',
		'attribs'
	],
	#category : 'RediStick-VectorSet',
	#package : 'RediStick-VectorSet'
}

{ #category : 'instance creation' }
RsVectorSetSimResult class >> element: anElementName score: aScoreOrNil attribs: anAttribsOrNil [
	^ self new
		setElement: anElementName
		score: aScoreOrNil
		attribs: anAttribsOrNil
]

{ #category : 'accessing' }
RsVectorSetSimResult >> attribs [
	^ attribs
]

{ #category : 'accessing' }
RsVectorSetSimResult >> element [
	^ element
]

{ #category : 'printing' }
RsVectorSetSimResult >> printOn: aStream [
	aStream
		nextPutAll: 'RsVectorSetSimResult(element: ';
		print: self element;
		nextPutAll: ' score: ';
		print: self score;
		nextPutAll: ' attribs: ';
		print: self attribs;
		nextPut: $)
]

{ #category : 'accessing' }
RsVectorSetSimResult >> score [
	^ score
]

{ #category : 'private' }
RsVectorSetSimResult >> setElement: anElementName score: aScoreOrNil attribs: anAttribsOrNil [
	element := anElementName.
	score := aScoreOrNil.
	attribs := anAttribsOrNil
]
