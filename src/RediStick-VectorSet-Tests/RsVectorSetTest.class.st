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
