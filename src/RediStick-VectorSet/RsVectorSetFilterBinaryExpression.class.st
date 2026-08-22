"
I am the abstract superclass for binary logical combinators (AND, OR) in a
VSIM FILTER expression built fluently.

Responsibility:
- I render `<left> <keyword> <right>`, parenthesizing either child whose
  precedence is lower than my own so that, e.g., `(A or B) and C` keeps
  its grouping when rendered, while a simple two-term AND or OR (whose
  children are both comparisons) renders without superfluous parens.

Collaborators:
- RsVectorSetFilterAnd, RsVectorSetFilterOr: concrete subclasses,
  answered by RsVectorSetFilterExpression's #& and #|.

Public API and Key Messages:
- #left:right: - sets my operands.
- #left, #right - accessors for the operands set above.
- #asFilterString - answers the rendered combination.
- #operatorKeyword - subclassResponsibility; 'and' or 'or'.

Internal Representation:
- left, right - RsVectorSetFilterExpression, my operands.
"
Class {
	#name : 'RsVectorSetFilterBinaryExpression',
	#superclass : 'RsVectorSetFilterExpression',
	#instVars : [
		'left',
		'right'
	],
	#category : 'RediStick-VectorSet',
	#package : 'RediStick-VectorSet'
}

{ #category : 'accessing' }
RsVectorSetFilterBinaryExpression >> left [
	^ left
]

{ #category : 'accessing' }
RsVectorSetFilterBinaryExpression >> left: aLeftExpression right: aRightExpression [
	left := aLeftExpression.
	right := aRightExpression
]

{ #category : 'accessing' }
RsVectorSetFilterBinaryExpression >> right [
	^ right
]

{ #category : 'converting' }
RsVectorSetFilterBinaryExpression >> asFilterString [
	^ '{1} {2} {3}' format:
		{ self render: self left. self operatorKeyword. self render: self right }
]

{ #category : 'private' }
RsVectorSetFilterBinaryExpression >> render: aChildExpression [
	aChildExpression precedence < self precedence
		ifTrue: [ ^ '(', aChildExpression asFilterString, ')' ].
	^ aChildExpression asFilterString
]

{ #category : 'accessing' }
RsVectorSetFilterBinaryExpression >> operatorKeyword [
	^ self subclassResponsibility
]
