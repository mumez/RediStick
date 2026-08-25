"
I represent a reference to an element attribute (e.g. `.year`) within a
fluent VSIM FILTER expression, answered by RsVectorSetFilterElement>>#@.

Responsibility:
- I turn comparisons against a Smalltalk literal (Number, String, or
  Collection) into RsVectorSetFilterComparison nodes.

Collaborators:
- RsVectorSetFilterElement: creates instances of me via #@.
- RsVectorSetFilterComparison: answered by my comparison messages.

Public API and Key Messages:
- #name - the attribute's dot-path name, without the leading dot.
- #=, #~=, #>, #>=, #<, #<= - comparisons against a Number or String
  literal, rendering as ==, !=, >, >=, <, <=.
- #in: - membership comparison against a Collection literal, rendering
  as `in [...]`.

Internal Representation:
- name - String, the attribute's dot-path name without the leading dot.
"
Class {
	#name : 'RsVectorSetFilterAttribute',
	#superclass : 'Object',
	#instVars : [
		'name'
	],
	#category : 'RediStick-VectorSet',
	#package : 'RediStick-VectorSet'
}

{ #category : 'accessing' }
RsVectorSetFilterAttribute >> name [
	^ name
]

{ #category : 'accessing' }
RsVectorSetFilterAttribute >> name: aString [
	name := aString
]

{ #category : 'comparing' }
RsVectorSetFilterAttribute >> = aValue [
	^ RsVectorSetFilterComparison new attribute: self operator: '==' value: aValue
]

{ #category : 'comparing' }
RsVectorSetFilterAttribute >> ~= aValue [
	^ RsVectorSetFilterComparison new attribute: self operator: '!=' value: aValue
]

{ #category : 'comparing' }
RsVectorSetFilterAttribute >> > aValue [
	^ RsVectorSetFilterComparison new attribute: self operator: '>' value: aValue
]

{ #category : 'comparing' }
RsVectorSetFilterAttribute >> >= aValue [
	^ RsVectorSetFilterComparison new attribute: self operator: '>=' value: aValue
]

{ #category : 'comparing' }
RsVectorSetFilterAttribute >> < aValue [
	^ RsVectorSetFilterComparison new attribute: self operator: '<' value: aValue
]

{ #category : 'comparing' }
RsVectorSetFilterAttribute >> <= aValue [
	^ RsVectorSetFilterComparison new attribute: self operator: '<=' value: aValue
]

{ #category : 'comparing' }
RsVectorSetFilterAttribute >> in: aCollection [
	^ RsVectorSetFilterComparison new attribute: self operator: 'in' value: aCollection
]
