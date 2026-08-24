Class {
	#name : 'RsVectorSetTestCase',
	#superclass : 'RsRedisTestCase',
	#category : 'RediStick-VectorSet-Tests',
	#package : 'RediStick-VectorSet-Tests'
}

{ #category : 'fixtures' }
RsVectorSetTestCase class >> sampleVectorA [
	"Small fixture vector standing in for a real embedding (e.g. from
	OllamaClient embed:model:). Kept as a literal so tests don't depend on a
	live embedding server."

	^ #(0.1 0.2 0.3 0.4)
]

{ #category : 'fixtures' }
RsVectorSetTestCase class >> sampleVectorB [
	"Close to sampleVectorA, for asserting nearest-neighbor ordering."

	^ #(0.11 0.19 0.31 0.41)
]

{ #category : 'fixtures' }
RsVectorSetTestCase class >> sampleVectorC [
	"Far from sampleVectorA/sampleVectorB, for asserting nearest-neighbor ordering."

	^ #(-0.4 -0.3 -0.2 -0.1)
]

{ #category : 'fixtures' }
RsVectorSetTestCase class >> fp32BytesFor: aNumberCollection [
	"Encodes a numeric vector as 32-bit floats in little-endian byte order,
	as required by Redis's FP32 blob format for VADD/VSIM."
	| bytes |
	bytes := ByteArray new: aNumberCollection size * 4.
	aNumberCollection doWithIndex: [ :each :index |
		| word offset |
		word := each asFloat asIEEE32BitWord.
		offset := (index - 1) * 4.
		1 to: 4 do: [ :i | bytes at: offset + i put: ((word >> ((i - 1) * 8)) bitAnd: 255) ] ].
	^ bytes
]

{ #category : 'fixtures' }
RsVectorSetTestCase class >> floatsFromFp32Bytes: aByteArray [
	"Inverse of #fp32BytesFor: - decodes 32-bit little-endian float bytes
	(as answered by VEMB ... RAW for fp32/NOQUANT vectors) back into Floats."
	| count floats |
	count := aByteArray size // 4.
	floats := Array new: count.
	1 to: count do: [ :index |
		| word offset |
		offset := (index - 1) * 4.
		word := 0.
		4 to: 1 by: -1 do: [ :i | word := (word << 8) bitOr: (aByteArray at: offset + i) ].
		floats at: index put: (Float fromIEEE32Bit: word) ].
	^ floats
]
