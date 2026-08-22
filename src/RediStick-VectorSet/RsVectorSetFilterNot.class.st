"
I represent a logical negation of a VSIM FILTER expression, rendering as
`!(<operand>)`. The operand is always parenthesized, so I compose safely
regardless of what kind of expression I negate.

Responsibility:
- I render `!(<operand>)`.

Collaborators:
- RsVectorSetFilterExpression: creates instances of me via #not.

Public API and Key Messages:
- #operand: - sets the expression I negate.
- #operand - accessor for the expression set above.
- #asFilterString - answers the rendered negation.
- #precedence - answers 3, the highest precedence (an atom, never needs
  parenthesizing as a child of an AND/OR node).

Internal Representation:
- operand - RsVectorSetFilterExpression, the expression I negate.
"
Class {
	#name : 'RsVectorSetFilterNot',
	#superclass : 'RsVectorSetFilterExpression',
	#instVars : [
		'operand'
	],
	#category : 'RediStick-VectorSet',
	#package : 'RediStick-VectorSet'
}

{ #category : 'accessing' }
RsVectorSetFilterNot >> operand [
	^ operand
]

{ #category : 'accessing' }
RsVectorSetFilterNot >> operand: anExpression [
	operand := anExpression
]

{ #category : 'converting' }
RsVectorSetFilterNot >> asFilterString [
	^ '!(', self operand asFilterString, ')'
]

{ #category : 'accessing' }
RsVectorSetFilterNot >> precedence [
	^ 3
]
