"
I am a leaf boolean expression node representing a single comparison
between an element attribute and a literal value, within a VSIM FILTER
expression built fluently (e.g. `.year >= 1980` or `.color in [""red""]`).

Responsibility:
- I render myself as `.<name> <operator> <value>`, quoting String values
  and bracketing/quoting Collection values for the `in` operator.

Collaborators:
- RsVectorSetFilterAttribute: creates instances of me via its comparison
  messages (#=, #~=, #>, #>=, #<, #<=, #in:).

Public API and Key Messages:
- #attribute:operator:value: - sets my attribute, operator token, and
  literal value.
- #attribute, #operator, #value - accessors for the parts set above.
- #asFilterString - answers the rendered comparison.
- #precedence - answers 3, the highest precedence (an atom, never needs
  parenthesizing as a child of an AND/OR node).

Internal Representation:
- attribute - RsVectorSetFilterAttribute, the left-hand attribute
  reference.
- operator - String, one of '==', '!=', '>', '>=', '<', '<=', 'in'.
- value - Number, String, or Collection, the right-hand literal.
"
Class {
	#name : 'RsVectorSetFilterComparison',
	#superclass : 'RsVectorSetFilterExpression',
	#instVars : [
		'attribute',
		'operator',
		'value'
	],
	#category : 'RediStick-VectorSet',
	#package : 'RediStick-VectorSet'
}

{ #category : 'accessing' }
RsVectorSetFilterComparison >> attribute [
	^ attribute
]

{ #category : 'accessing' }
RsVectorSetFilterComparison >> attribute: anAttribute operator: anOperatorString value: aValue [
	attribute := anAttribute.
	operator := anOperatorString.
	value := aValue
]

{ #category : 'accessing' }
RsVectorSetFilterComparison >> operator [
	^ operator
]

{ #category : 'accessing' }
RsVectorSetFilterComparison >> value [
	^ value
]

{ #category : 'converting' }
RsVectorSetFilterComparison >> asFilterString [
	self operator = 'in'
		ifTrue: [ ^ '.{1} in {2}' format: { self attribute name. self renderLiteral: self value } ].
	^ '.{1} {2} {3}' format: { self attribute name. self operator. self renderLiteral: self value }
]

{ #category : 'accessing' }
RsVectorSetFilterComparison >> precedence [
	^ 3
]

{ #category : 'private' }
RsVectorSetFilterComparison >> renderLiteral: aValue [
	aValue isString ifTrue: [ ^ '"', aValue, '"' ].
	aValue isCollection ifTrue: [
		^ '[{1}]' format: { ', ' join: (aValue collect: [ :each | self renderLiteral: each ]) } ].
	^ aValue printString
]
