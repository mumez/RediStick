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
