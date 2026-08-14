"
I represent the query subject for Redis's VSIM command.

Responsibility:
- I hold either an element name (ELE form) or a raw vector (VALUES form)
  for a similarity search, but not both.

Collaborators:
- RsRedisEndpoint: sends #vSim:queryBy:using: with a block that receives
  a new instance of me, then reads #element/#values to assemble the VSIM
  command.

Public API and Key Messages:
- #element: - sets the element name to search by (ELE form).
- #values: - sets the raw vector (Collection of numbers) to search by
  (VALUES form).
- #validate - raises RsError invalidArguments when neither element nor
  values has been set.

Internal Representation:
- element - element name for the ELE form, or nil.
- values - Collection of numbers for the VALUES form, or nil.
"
Class {
	#name : 'RsVectorSetSimQuery',
	#superclass : 'Object',
	#instVars : [
		'element',
		'values'
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

{ #category : 'validation' }
RsVectorSetSimQuery >> validate [
	(self element isNil and: [ self values isNil ])
		ifTrue: [
			^ (RsError invalidArguments) signal:
				'VSIM requires either element: or values: to be set' ]
]
