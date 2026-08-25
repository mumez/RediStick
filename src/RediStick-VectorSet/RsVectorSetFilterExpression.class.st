"
I am the abstract superclass for boolean expression nodes used to build a
VSIM FILTER string fluently (comparisons, AND, OR, NOT).

Responsibility:
- I provide the combinators (#&, #|, #not) shared by all expression nodes,
  and declare the #asFilterString/#precedence protocol subclasses must
  implement to render themselves (with parentheses only where needed to
  preserve grouping).

Collaborators:
- RsVectorSetFilterComparison: leaf expression nodes, answered by
  RsVectorSetFilterAttribute's comparison messages.
- RsVectorSetFilterAnd, RsVectorSetFilterOr: answered by #& and #|.
- RsVectorSetFilterNot: answered by #not.

Public API and Key Messages:
- #& anExpression - answers an RsVectorSetFilterAnd combining self and
  anExpression.
- #| anExpression - answers an RsVectorSetFilterOr combining self and
  anExpression.
- #not - answers an RsVectorSetFilterNot negating self.
- #asFilterString - subclassResponsibility; answers the VSIM FILTER
  string for this node.
- #precedence - subclassResponsibility; used by binary nodes to decide
  whether a child needs parenthesizing.

Internal Representation:
- (none)
"
Class {
	#name : 'RsVectorSetFilterExpression',
	#superclass : 'Object',
	#category : 'RediStick-VectorSet',
	#package : 'RediStick-VectorSet'
}

{ #category : 'combining' }
RsVectorSetFilterExpression >> & anExpression [
	^ RsVectorSetFilterAnd new left: self right: anExpression
]

{ #category : 'combining' }
RsVectorSetFilterExpression >> | anExpression [
	^ RsVectorSetFilterOr new left: self right: anExpression
]

{ #category : 'combining' }
RsVectorSetFilterExpression >> not [
	^ RsVectorSetFilterNot new operand: self
]

{ #category : 'converting' }
RsVectorSetFilterExpression >> asFilterString [
	^ self subclassResponsibility
]

{ #category : 'accessing' }
RsVectorSetFilterExpression >> precedence [
	^ self subclassResponsibility
]
