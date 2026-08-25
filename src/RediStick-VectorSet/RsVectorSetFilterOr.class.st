"
I represent a logical OR of two VSIM FILTER expressions, rendering as
`<left> or <right>`. See RsVectorSetFilterBinaryExpression.
"
Class {
	#name : 'RsVectorSetFilterOr',
	#superclass : 'RsVectorSetFilterBinaryExpression',
	#category : 'RediStick-VectorSet',
	#package : 'RediStick-VectorSet'
}

{ #category : 'accessing' }
RsVectorSetFilterOr >> operatorKeyword [
	^ 'or'
]

{ #category : 'accessing' }
RsVectorSetFilterOr >> precedence [
	^ 1
]
