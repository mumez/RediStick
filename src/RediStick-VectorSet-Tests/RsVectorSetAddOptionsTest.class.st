Class {
	#name : 'RsVectorSetAddOptionsTest',
	#superclass : 'TestCase',
	#category : 'RediStick-VectorSet-Tests',
	#package : 'RediStick-VectorSet-Tests'
}

{ #category : 'tests' }
RsVectorSetAddOptionsTest >> testEmptyOptionsProduceEmptyArray [
	self assertCollection: RsVectorSetAddOptions new asArray equals: #()
]

{ #category : 'tests' }
RsVectorSetAddOptionsTest >> testCasFlag [
	| opts |
	opts := RsVectorSetAddOptions new.
	opts cas.
	self assertCollection: opts asArray equals: { 'CAS' }
]

{ #category : 'tests' }
RsVectorSetAddOptionsTest >> testQuantizationNoQuant [
	| opts |
	opts := RsVectorSetAddOptions new.
	opts noQuantization.
	self assertCollection: opts asArray equals: { 'NOQUANT' }
]

{ #category : 'tests' }
RsVectorSetAddOptionsTest >> testQuantizationQ8 [
	| opts |
	opts := RsVectorSetAddOptions new.
	opts quantizationQ8.
	self assertCollection: opts asArray equals: { 'Q8' }
]

{ #category : 'tests' }
RsVectorSetAddOptionsTest >> testQuantizationBin [
	| opts |
	opts := RsVectorSetAddOptions new.
	opts quantizationBin.
	self assertCollection: opts asArray equals: { 'BIN' }
]

{ #category : 'tests' }
RsVectorSetAddOptionsTest >> testEf [
	| opts |
	opts := RsVectorSetAddOptions new.
	opts explorationFactor: 100.
	self assertCollection: opts asArray equals: { 'EF'. 100 }
]

{ #category : 'tests' }
RsVectorSetAddOptionsTest >> testM [
	| opts |
	opts := RsVectorSetAddOptions new.
	opts maxConnections: 8.
	self assertCollection: opts asArray equals: { 'M'. 8 }
]

{ #category : 'tests' }
RsVectorSetAddOptionsTest >> testSetAttrWithJsonString [
	| opts |
	opts := RsVectorSetAddOptions new.
	opts setAttr: '{"foo":"bar"}'.
	self assertCollection: opts asArray equals: { 'SETATTR'. '{"foo":"bar"}' }
]

{ #category : 'tests' }
RsVectorSetAddOptionsTest >> testSetAttrWithSmalltalkObjectConvertsToJson [
	| opts |
	opts := RsVectorSetAddOptions new.
	opts setAttr: ({ 'foo' -> 'bar' } asDictionary).
	self assertCollection: opts asArray equals: { 'SETATTR'. '{"foo":"bar"}' }
]

{ #category : 'tests' }
RsVectorSetAddOptionsTest >> testReduceDimIsNotPartOfAsArray [
	"REDUCE precedes the vector in VADD's wire format, so it is read directly
	via the reduceDim accessor by the endpoint rather than emitted by asArray,
	which only covers tokens placed after the vector/element."
	| opts |
	opts := RsVectorSetAddOptions new.
	opts reduceDim: 2.
	self assertCollection: opts asArray equals: #()
]

{ #category : 'tests' }
RsVectorSetAddOptionsTest >> testAllOptionsCombinedInRedisOrder [
	| opts |
	opts := RsVectorSetAddOptions new.
	opts
		cas;
		quantizationQ8;
		explorationFactor: 100;
		setAttr: '{"foo":"bar"}';
		maxConnections: 8.
	self assertCollection: opts asArray
		equals: { 'CAS'. 'Q8'. 'EF'. 100. 'SETATTR'. '{"foo":"bar"}'. 'M'. 8 }
]
