"
I represent the query subject for Redis's VSIM command.

Responsibility:
- I hold exactly one of: an element name (ELE form), a raw numeric vector
  (VALUES form), or a raw FP32 vector blob (FP32 form) for a similarity
  search.

Collaborators:
- RsRedisEndpoint: sends #vSim:queryBy:using: with a block that receives
  a new instance of me, then reads #element/#values/#valuesFp32 to
  assemble the VSIM command.

Public API and Key Messages:
- #element: - sets the element name to search by (ELE form).
- #values: - sets the raw vector (Collection of numbers) to search by
  (VALUES form).
- #valuesFp32: - sets the raw vector as a ByteArray of 32-bit floats in
  little-endian byte order to search by (FP32 form).
- #validate - raises RsError invalidArguments when none of element,
  values, or valuesFp32 has been set.

Internal Representation:
- element - element name for the ELE form, or nil.
- values - Collection of numbers for the VALUES form, or nil.
- valuesFp32 - ByteArray for the FP32 form, or nil.
"
Class {
	#name : 'RsVectorSetSimQuery',
	#superclass : 'Object',
	#instVars : [
		'element',
		'values',
		'valuesFp32'
	],
	#category : 'RediStick-VectorSet',
	#package : 'RediStick-VectorSet'
}

{ #category : 'accessing' }
RsVectorSetSimQuery >> element [
	^ element
]

{ #category : 'accessing' }
RsVectorSetSimQuery >> element: anElementName [
	element := anElementName
]

{ #category : 'accessing' }
RsVectorSetSimQuery >> values [
	^ values
]

{ #category : 'accessing' }
RsVectorSetSimQuery >> values: aNumberCollection [
	values := aNumberCollection
]

{ #category : 'accessing' }
RsVectorSetSimQuery >> valuesFp32 [
	^ valuesFp32
]

{ #category : 'accessing' }
RsVectorSetSimQuery >> valuesFp32: aByteArray [
	valuesFp32 := aByteArray
]

{ #category : 'validation' }
RsVectorSetSimQuery >> validate [
	(self element isNil and: [ self values isNil and: [ self valuesFp32 isNil ] ])
		ifTrue: [
			^ (RsError invalidArguments) signal:
				'VSIM requires one of element:, values:, or valuesFp32: to be set' ]
]
