"
I represent the parsed reply of a Redis VEMB ... RAW command.

Responsibility:
- I wrap the raw quantized embedding bytes together with the metadata
  needed to interpret them: the quantization type, the L2 norm applied
  before quantization, and (for Q8 only) the quantization range.

Collaborators:
- RsRedisEndpoint: builds instances of me from VEMB ... RAW replies in
  #vEmb:element:raw:.

Public API and Key Messages:
- #quantType - 'fp32', 'bin', or 'q8'.
- #bytes - the raw quantized vector as a ByteArray (4-byte little-endian
  floats for fp32, a bitmap for bin, a byte array for q8).
- #l2Norm - the L2 norm (Float) of the vector before normalization.
- #quantRange - the quantization range (Float), only present for q8;
  multiply by integer components to recover normalized values.

Internal Representation:
- quantType - String.
- bytes - ByteArray.
- l2Norm - Float.
- quantRange - Float or nil.
"
Class {
	#name : 'RsVectorSetRawEmbedding',
	#superclass : 'Object',
	#instVars : [
		'quantType',
		'bytes',
		'l2Norm',
		'quantRange'
	],
	#category : 'RediStick-VectorSet',
	#package : 'RediStick-VectorSet'
}

{ #category : 'instance creation' }
RsVectorSetRawEmbedding class >> quantType: aQuantTypeString bytes: aByteArray l2Norm: aL2Norm quantRange: aQuantRangeOrNil [
	^ self new
		setQuantType: aQuantTypeString
		bytes: aByteArray
		l2Norm: aL2Norm
		quantRange: aQuantRangeOrNil
]

{ #category : 'accessing' }
RsVectorSetRawEmbedding >> bytes [
	^ bytes
]

{ #category : 'accessing' }
RsVectorSetRawEmbedding >> l2Norm [
	^ l2Norm
]

{ #category : 'printing' }
RsVectorSetRawEmbedding >> printOn: aStream [
	aStream
		nextPutAll: 'RsVectorSetRawEmbedding(quantType: ';
		print: self quantType;
		nextPutAll: ' bytes: ';
		print: self bytes size;
		nextPutAll: ' bytes l2Norm: ';
		print: self l2Norm;
		nextPutAll: ' quantRange: ';
		print: self quantRange;
		nextPut: $)
]

{ #category : 'accessing' }
RsVectorSetRawEmbedding >> quantRange [
	^ quantRange
]

{ #category : 'accessing' }
RsVectorSetRawEmbedding >> quantType [
	^ quantType
]

{ #category : 'private' }
RsVectorSetRawEmbedding >> setQuantType: aQuantTypeString bytes: aByteArray l2Norm: aL2Norm quantRange: aQuantRangeOrNil [
	quantType := aQuantTypeString.
	bytes := aByteArray.
	l2Norm := aL2Norm.
	quantRange := aQuantRangeOrNil
]
