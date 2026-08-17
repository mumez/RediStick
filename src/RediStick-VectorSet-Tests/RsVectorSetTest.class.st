Class {
	#name : 'RsVectorSetTest',
	#superclass : 'RsVectorSetTestCase',
	#category : 'RediStick-VectorSet-Tests',
	#package : 'RediStick-VectorSet-Tests'
}

{ #category : 'tests' }
RsVectorSetTest >> testVAddWithoutOptionsReturnsTrueForNewElement [
	| result |
	result := stick endpoint
		vAdd: 'vs:test'
		element: 'elem1'
		vector: self class sampleVectorA
		using: nil.
	self assert: result equals: true
]

{ #category : 'tests' }
RsVectorSetTest >> testVAddReAddingSameElementReturnsFalse [
	stick endpoint vAdd: 'vs:test' element: 'elem1' vector: self class sampleVectorA using: nil.
	self assert:
		(stick endpoint vAdd: 'vs:test' element: 'elem1' vector: self class sampleVectorA using: nil)
		equals: false
]

{ #category : 'tests' }
RsVectorSetTest >> testVAddWithReduce [
	| result |
	result := stick endpoint
		vAdd: 'vs:reduce'
		element: 'elem1'
		vector: self class sampleVectorA
		using: [ :opts | opts reduceDim: 2 ].
	self assert: result equals: true.
	self assert: (stick endpoint unifiedCommand: { 'VDIM'. 'vs:reduce' }) equals: 2
]

{ #category : 'tests' }
RsVectorSetTest >> testVAddWithCas [
	| result |
	result := stick endpoint
		vAdd: 'vs:cas'
		element: 'elem1'
		vector: self class sampleVectorA
		using: [ :opts | opts cas ].
	self assert: result equals: true
]

{ #category : 'tests' }
RsVectorSetTest >> testVAddWithNoQuant [
	| result |
	result := stick endpoint
		vAdd: 'vs:noquant'
		element: 'elem1'
		vector: self class sampleVectorA
		using: [ :opts | opts quantization: #noQuant ].
	self assert: result equals: true
]

{ #category : 'tests' }
RsVectorSetTest >> testVAddWithQ8 [
	| result |
	result := stick endpoint
		vAdd: 'vs:q8'
		element: 'elem1'
		vector: self class sampleVectorA
		using: [ :opts | opts quantization: #q8 ].
	self assert: result equals: true
]

{ #category : 'tests' }
RsVectorSetTest >> testVAddWithBin [
	| result |
	result := stick endpoint
		vAdd: 'vs:bin'
		element: 'elem1'
		vector: self class sampleVectorA
		using: [ :opts | opts quantization: #bin ].
	self assert: result equals: true
]

{ #category : 'tests' }
RsVectorSetTest >> testVAddWithSetAttr [
	| result attr |
	result := stick endpoint
		vAdd: 'vs:setattr'
		element: 'elem1'
		vector: self class sampleVectorA
		using: [ :opts | opts setAttr: ({ 'foo' -> 'bar' } asDictionary) ].
	self assert: result equals: true.
	attr := stick endpoint unifiedCommand: { 'VGETATTR'. 'vs:setattr'. 'elem1' }.
	self assert: attr equals: '{"foo":"bar"}'
]

{ #category : 'tests' }
RsVectorSetTest >> testVAddWithMAndEf [
	| result |
	result := stick endpoint
		vAdd: 'vs:mef'
		element: 'elem1'
		vector: self class sampleVectorA
		using: [ :opts |
			opts m: 8.
			opts ef: 100 ].
	self assert: result equals: true
]

{ #category : 'tests' }
RsVectorSetTest >> testVCardAndVDim [
	stick endpoint vAdd: 'vs:cardinality' element: 'elem1' vector: self class sampleVectorA using: nil.
	stick endpoint vAdd: 'vs:cardinality' element: 'elem2' vector: self class sampleVectorB using: nil.
	self assert: (stick endpoint vCard: 'vs:cardinality') equals: 2.
	self assert: (stick endpoint vDim: 'vs:cardinality') equals: self class sampleVectorA size
]

{ #category : 'tests' }
RsVectorSetTest >> testVCardAndVDimOnMissingKey [
	self assert: (stick endpoint vCard: 'vs:doesNotExist') equals: 0.
	self assert: (stick endpoint vDim: 'vs:doesNotExist') equals: nil
]

{ #category : 'tests' }
RsVectorSetTest >> testVEmbRoundTrip [
	| embedding original |
	stick endpoint vAdd: 'vs:emb' element: 'elem1' vector: self class sampleVectorA using: nil.
	embedding := stick endpoint vEmb: 'vs:emb' element: 'elem1'.
	original := self class sampleVectorA.
	self assert: embedding size equals: original size.
	embedding with: original do: [ :actual :expected |
		self assert: (actual - expected) abs < 0.01 ]
]

{ #category : 'tests' }
RsVectorSetTest >> testVEmbRaw [
	| raw |
	stick endpoint vAdd: 'vs:embraw' element: 'elem1' vector: self class sampleVectorA using: nil.
	raw := stick endpoint vEmb: 'vs:embraw' element: 'elem1' raw: true.
	self assert: raw first equals: 'int8'.
	self assert: (stick endpoint vEmb: 'vs:embraw' element: 'elem1' raw: false)
		equals: (stick endpoint vEmb: 'vs:embraw' element: 'elem1')
]

{ #category : 'tests' }
RsVectorSetTest >> testVEmbOnMissingElement [
	stick endpoint vAdd: 'vs:embmissing' element: 'elem1' vector: self class sampleVectorA using: nil.
	self assert: (stick endpoint vEmb: 'vs:embmissing' element: 'nope') equals: nil
]

{ #category : 'tests' }
RsVectorSetTest >> testVRem [
	stick endpoint vAdd: 'vs:rem' element: 'elem1' vector: self class sampleVectorA using: nil.
	self assert: (stick endpoint vRem: 'vs:rem' element: 'elem1') equals: true.
	self assert: (stick endpoint vCard: 'vs:rem') equals: 0.
	self assert: (stick endpoint vEmb: 'vs:rem' element: 'elem1') equals: nil.
	self assert: (stick endpoint vRem: 'vs:rem' element: 'elem1') equals: false
]

{ #category : 'tests' }
RsVectorSetTest >> testVInfo [
	| info |
	stick endpoint vAdd: 'vs:info' element: 'elem1' vector: self class sampleVectorA using: nil.
	stick endpoint vAdd: 'vs:info' element: 'elem2' vector: self class sampleVectorB using: nil.
	info := stick endpoint vInfo: 'vs:info'.
	self assert: (info at: 'size') equals: 2.
	self assert: (info at: 'vector-dim') equals: self class sampleVectorA size.
	self assert: (info at: 'quant-type') equals: 'int8'
]

{ #category : 'tests' }
RsVectorSetTest >> testVInfoOnMissingKey [
	self assert: (stick endpoint vInfo: 'vs:doesNotExist') equals: nil
]

{ #category : 'tests' }
RsVectorSetTest >> testVGetAttrWithNoAttributesReturnsNil [
	stick endpoint vAdd: 'vs:getattr' element: 'elem1' vector: self class sampleVectorA using: nil.
	self assert: (stick endpoint vGetAttr: 'vs:getattr' element: 'elem1') equals: nil
]

{ #category : 'tests' }
RsVectorSetTest >> testVSetAttrThenVGetAttrRoundTrip [
	| attr |
	stick endpoint vAdd: 'vs:setgetattr' element: 'elem1' vector: self class sampleVectorA using: nil.
	self assert:
		(stick endpoint vSetAttr: 'vs:setgetattr' element: 'elem1' value: ({ 'foo' -> 'bar' } asDictionary))
		equals: true.
	attr := stick endpoint vGetAttr: 'vs:setgetattr' element: 'elem1'.
	self assert: (attr at: 'foo') equals: 'bar'
]

{ #category : 'tests' }
RsVectorSetTest >> testVSetAttrWithJsonStringOverwritesExisting [
	stick endpoint vAdd: 'vs:overwriteattr' element: 'elem1' vector: self class sampleVectorA using: nil.
	stick endpoint vSetAttr: 'vs:overwriteattr' element: 'elem1' value: ({ 'foo' -> 'bar' } asDictionary).
	stick endpoint vSetAttr: 'vs:overwriteattr' element: 'elem1' value: '{"baz":42}'.
	self assert: (stick endpoint vGetAttr: 'vs:overwriteattr' element: 'elem1') equals: ({ 'baz' -> 42 } asDictionary)
]

{ #category : 'tests' }
RsVectorSetTest >> testVSetAttrOnMissingElementReturnsFalse [
	stick endpoint vAdd: 'vs:missingattr' element: 'elem1' vector: self class sampleVectorA using: nil.
	self assert:
		(stick endpoint vSetAttr: 'vs:missingattr' element: 'noSuchElem' value: '{"a":1}')
		equals: false
]

{ #category : 'tests' }
RsVectorSetTest >> testVGetAttrOnMissingKeyReturnsNil [
	self assert: (stick endpoint vGetAttr: 'vs:doesNotExist' element: 'elem1') equals: nil
]

{ #category : 'tests' }
RsVectorSetTest >> testVAddSetAttrThenVGetAttrSeesIt [
	stick endpoint
		vAdd: 'vs:addsetattr'
		element: 'elem1'
		vector: self class sampleVectorA
		using: [ :opts | opts setAttr: ({ 'foo' -> 'bar' } asDictionary) ].
	self assert:
		((stick endpoint vGetAttr: 'vs:addsetattr' element: 'elem1') at: 'foo')
		equals: 'bar'
]

{ #category : 'helpers' }
RsVectorSetTest >> setUpSimTestSet: key [
	stick endpoint vAdd: key element: 'elemA' vector: self class sampleVectorA using: nil.
	stick endpoint vAdd: key element: 'elemB' vector: self class sampleVectorB using: nil.
	stick endpoint vAdd: key element: 'elemC' vector: self class sampleVectorC using: nil
]

{ #category : 'tests' }
RsVectorSetTest >> testVSimByElement [
	| results |
	self setUpSimTestSet: 'vs:sim:ele'.
	results := stick endpoint vSim: 'vs:sim:ele' queryBy: [ :q | q element: 'elemA' ].
	self assert: (results collect: [ :each | each element ]) asArray
		equals: #('elemA' 'elemB' 'elemC').
	results do: [ :each |
		self assert: each score equals: nil.
		self assert: each attribs equals: nil ]
]

{ #category : 'tests' }
RsVectorSetTest >> testVSimByValues [
	"Uses TRUTH (exact linear search) since the raw query vector ties in
	similarity with elemA/elemB under approximate HNSW search against
	int8-quantized stored vectors, making the plain approximate order
	non-deterministic between them."
	| results |
	self setUpSimTestSet: 'vs:sim:values'.
	results := stick endpoint
		vSim: 'vs:sim:values'
		queryBy: [ :q | q values: self class sampleVectorA ]
		using: [ :opts | opts truth ].
	self assert: (results collect: [ :each | each element ]) asArray
		equals: #('elemA' 'elemB' 'elemC')
]

{ #category : 'tests' }
RsVectorSetTest >> testVSimWithCount [
	| results |
	self setUpSimTestSet: 'vs:sim:count'.
	results := stick endpoint
		vSim: 'vs:sim:count'
		queryBy: [ :q | q element: 'elemA' ]
		using: [ :opts | opts count: 2 ].
	self assert: results size equals: 2.
	self assert: (results collect: [ :each | each element ]) asArray
		equals: #('elemA' 'elemB')
]

{ #category : 'tests' }
RsVectorSetTest >> testVSimWithScores [
	| results |
	self setUpSimTestSet: 'vs:sim:scores'.
	results := stick endpoint
		vSim: 'vs:sim:scores'
		queryBy: [ :q | q element: 'elemA' ]
		using: [ :opts | opts withScores ].
	self assert: (results first) element equals: 'elemA'.
	self assert: (results first) score equals: 1.
	self assert: (results first) attribs equals: nil.
	self assert: results second score > results third score
]

{ #category : 'tests' }
RsVectorSetTest >> testVSimWithAttribs [
	| results |
	self setUpSimTestSet: 'vs:sim:attribs'.
	stick endpoint vSetAttr: 'vs:sim:attribs' element: 'elemA' value: ({ 'foo' -> 'bar' } asDictionary).
	results := stick endpoint
		vSim: 'vs:sim:attribs'
		queryBy: [ :q | q element: 'elemA' ]
		using: [ :opts | opts withAttribs ].
	self assert: (results first attribs at: 'foo') equals: 'bar'.
	self assert: results second score equals: nil.
	self assert: results second attribs equals: nil
]

{ #category : 'tests' }
RsVectorSetTest >> testVSimWithFilter [
	| results |
	self setUpSimTestSet: 'vs:sim:filter'.
	stick endpoint vSetAttr: 'vs:sim:filter' element: 'elemA' value: ({ 'foo' -> 'bar' } asDictionary).
	results := stick endpoint
		vSim: 'vs:sim:filter'
		queryBy: [ :q | q element: 'elemA' ]
		using: [ :opts | opts filter: '.foo == "bar"' ].
	self assert: (results collect: [ :each | each element ]) asArray equals: #('elemA')
]

{ #category : 'tests' }
RsVectorSetTest >> testVSimWithCombinedOptions [
	| results |
	self setUpSimTestSet: 'vs:sim:combined'.
	stick endpoint vSetAttr: 'vs:sim:combined' element: 'elemA' value: ({ 'foo' -> 'bar' } asDictionary).
	results := stick endpoint
		vSim: 'vs:sim:combined'
		queryBy: [ :q | q element: 'elemA' ]
		using: [ :opts |
			opts withScores.
			opts withAttribs.
			opts count: 2 ].
	self assert: results size equals: 2.
	self assert: results first element equals: 'elemA'.
	self assert: results first score equals: 1.
	self assert: (results first attribs at: 'foo') equals: 'bar'.
	self assert: results second attribs equals: nil
]

{ #category : 'tests' }
RsVectorSetTest >> testVSimWithNeitherElementNorValuesRaisesError [
	self setUpSimTestSet: 'vs:sim:neither'.
	self should: [ stick endpoint vSim: 'vs:sim:neither' queryBy: [ :q | ] ]
		raise: RsError
]

{ #category : 'tests' }
RsVectorSetTest >> testVectorSetSimQueryValidateSignalsErrorWhenNeitherSet [
	self should: [ RsVectorSetSimQuery new validate ] raise: RsError
]

{ #category : 'tests' }
RsVectorSetTest >> testVLinksWithoutScores [
	"HNSW layer assignment is randomized at VADD time, so neighbor order
	is not guaranteed across runs - check membership rather than order."
	| links |
	self setUpSimTestSet: 'vs:links'.
	links := stick endpoint vLinks: 'vs:links' element: 'elemA'.
	self assert: links asSet equals: #('elemB' 'elemC') asSet
]

{ #category : 'tests' }
RsVectorSetTest >> testVLinksWithScores [
	"HNSW layer assignment is randomized at VADD time, so neighbor order
	between elemB/elemC is not guaranteed across runs - check membership
	and score values rather than a fixed order."
	| links byElement |
	self setUpSimTestSet: 'vs:linksScores'.
	links := stick endpoint vLinks: 'vs:linksScores' element: 'elemA' withScores: true.
	byElement := Dictionary new.
	links do: [ :each | byElement at: each key put: each value ].
	self assert: byElement keys asSet equals: #('elemB' 'elemC') asSet.
	self assert: ((byElement at: 'elemB') - 1) abs < 0.01.
	self assert: (byElement at: 'elemB') > (byElement at: 'elemC')
]

{ #category : 'tests' }
RsVectorSetTest >> testVLinksWithScoresFalseSameAsWithoutScores [
	self setUpSimTestSet: 'vs:linksNoScoresFlag'.
	self assertCollection:
		(stick endpoint vLinks: 'vs:linksNoScoresFlag' element: 'elemA' withScores: false)
		equals: (stick endpoint vLinks: 'vs:linksNoScoresFlag' element: 'elemA')
]

{ #category : 'tests' }
RsVectorSetTest >> testVRandMemberSingleElement [
	| member |
	self setUpSimTestSet: 'vs:rand'.
	member := stick endpoint vRandMember: 'vs:rand'.
	self assert: (#('elemA' 'elemB' 'elemC') includes: member)
]

{ #category : 'tests' }
RsVectorSetTest >> testVRandMemberWithPositiveCount [
	| members |
	self setUpSimTestSet: 'vs:randPos'.
	members := stick endpoint vRandMember: 'vs:randPos' count: 2.
	self assert: members size equals: 2.
	members do: [ :each | self assert: (#('elemA' 'elemB' 'elemC') includes: each) ]
]

{ #category : 'tests' }
RsVectorSetTest >> testVRandMemberWithNegativeCount [
	| members |
	self setUpSimTestSet: 'vs:randNeg'.
	members := stick endpoint vRandMember: 'vs:randNeg' count: -5.
	self assert: members size equals: 5.
	members do: [ :each | self assert: (#('elemA' 'elemB' 'elemC') includes: each) ]
]

{ #category : 'tests' }
RsVectorSetTest >> testVLinksAndVRandMemberOnMissingKey [
	self assert: (stick endpoint vLinks: 'vs:doesNotExist' element: 'elemA') equals: nil.
	self assert: (stick endpoint vLinks: 'vs:doesNotExist' element: 'elemA' withScores: true) equals: nil.
	self assert: (stick endpoint vRandMember: 'vs:doesNotExist') equals: nil.
	self assertCollection: (stick endpoint vRandMember: 'vs:doesNotExist' count: 3) equals: #()
]
