"
I represent the optional parameters for Redis's VSIM command.

Responsibility:
- I build the token array (WITHSCORES, WITHATTRIBS, COUNT, EF, FILTER,
  FILTER-EF, TRUTH, NOTHREAD) appended after the query subject in VSIM's
  wire format.

Collaborators:
- RsRedisEndpoint: sends #vSim:queryBy:using: with an instance of me, then
  reads #asArray to assemble the VSIM command, and reads
  #isWithScores/#isWithAttribs to decide how to parse the reply.

Public API and Key Messages:
- #withScores, #withAttribs - request scores/attributes in the reply.
- #count:, #ef:, #filter:, #filterEf: - set the corresponding options.
- #truth, #noThread - request exact search / disable threaded search.
- #asArray - answers the ordered tokens for all set options.

Internal Representation:
- withScores, withAttribs, truth, noThread - Booleans; false until set.
- count, ef, filter, filterEf - option values, nil until set.
"
Class {
	#name : 'RsVectorSetSimOptions',
	#superclass : 'Object',
	#instVars : [
		'withScores',
		'withAttribs',
		'count',
		'ef',
		'filter',
		'filterEf',
		'truth',
		'noThread'
	],
	#category : 'RediStick-VectorSet',
	#package : 'RediStick-VectorSet'
}

{ #category : 'initialization' }
RsVectorSetSimOptions >> initialize [
	super initialize.
	withScores := false.
	withAttribs := false.
	truth := false.
	noThread := false
]

{ #category : 'converting' }
RsVectorSetSimOptions >> asArray [
	"Emits tokens in VSIM's wire format order: WITHSCORES, WITHATTRIBS,
	COUNT, EF, FILTER, FILTER-EF, TRUTH, NOTHREAD."
	| opts |
	opts := OrderedCollection new.
	self isWithScores ifTrue: [ opts add: 'WITHSCORES' ].
	self isWithAttribs ifTrue: [ opts add: 'WITHATTRIBS' ].
	self count ifNotNil: [ :c | opts addAll: { 'COUNT'. c } ].
	self ef ifNotNil: [ :e | opts addAll: { 'EF'. e } ].
	self filter ifNotNil: [ :f | opts addAll: { 'FILTER'. f } ].
	self filterEf ifNotNil: [ :fe | opts addAll: { 'FILTER-EF'. fe } ].
	self isTruth ifTrue: [ opts add: 'TRUTH' ].
	self isNoThread ifTrue: [ opts add: 'NOTHREAD' ].
	^ opts asArray
]

{ #category : 'accessing' }
RsVectorSetSimOptions >> count [
	^ count
]

{ #category : 'accessing' }
RsVectorSetSimOptions >> count: anInteger [
	count := anInteger
]

{ #category : 'accessing' }
RsVectorSetSimOptions >> ef [
	^ ef
]

{ #category : 'accessing' }
RsVectorSetSimOptions >> ef: anInteger [
	ef := anInteger
]

{ #category : 'actions' }
RsVectorSetSimOptions >> explorationFactor: anInteger [
	self ef: anInteger
]

{ #category : 'accessing' }
RsVectorSetSimOptions >> filter [
	^ filter
]

{ #category : 'accessing' }
RsVectorSetSimOptions >> filter: aFilterExpressionString [
	filter := aFilterExpressionString
]

{ #category : 'actions' }
RsVectorSetSimOptions >> filterBy: aBlock [
	"Fluent sugar over #filter:. Evaluates aBlock with an
	RsVectorSetFilterElement, then converts the resulting expression to a
	FILTER string via #asFilterString."
	self filter: (aBlock value: RsVectorSetFilterElement new) asFilterString
]

{ #category : 'accessing' }
RsVectorSetSimOptions >> filterEf [
	^ filterEf
]

{ #category : 'accessing' }
RsVectorSetSimOptions >> filterEf: anInteger [
	filterEf := anInteger
]

{ #category : 'actions' }
RsVectorSetSimOptions >> maxFilteringEffort: anInteger [
	self filterEf: anInteger
]

{ #category : 'testing' }
RsVectorSetSimOptions >> isNoThread [
	^ noThread
]

{ #category : 'testing' }
RsVectorSetSimOptions >> isTruth [
	^ truth
]

{ #category : 'testing' }
RsVectorSetSimOptions >> isWithAttribs [
	^ withAttribs
]

{ #category : 'testing' }
RsVectorSetSimOptions >> isWithScores [
	^ withScores
]

{ #category : 'actions' }
RsVectorSetSimOptions >> noThread [
	noThread := true
]

{ #category : 'actions' }
RsVectorSetSimOptions >> truth [
	truth := true
]

{ #category : 'actions' }
RsVectorSetSimOptions >> withAttribs [
	withAttribs := true
]

{ #category : 'actions' }
RsVectorSetSimOptions >> withScores [
	withScores := true
]
