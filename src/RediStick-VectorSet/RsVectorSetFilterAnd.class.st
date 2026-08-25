"
I represent a logical AND of two VSIM FILTER expressions, rendering as
`<left> and <right>`. See RsVectorSetFilterBinaryExpression.
"
Class {
	#name : 'RsVectorSetFilterAnd',
	#superclass : 'RsVectorSetFilterBinaryExpression',
	#category : 'RediStick-VectorSet',
	#package : 'RediStick-VectorSet'
}

{ #category : 'accessing' }
RsVectorSetFilterAnd >> operatorKeyword [
	^ 'and'
]

{ #category : 'accessing' }
RsVectorSetFilterAnd >> precedence [
	^ 2
]
