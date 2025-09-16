Class {
	#name : 'RsJsonMultiSetValues',
	#superclass : 'Object',
	#instVars : [
		'params'
	],
	#category : 'RediStick-Json',
	#package : 'RediStick-Json'
}

{ #category : 'initialization' }
RsJsonMultiSetValues >> initialize [
	params := OrderedCollection new
]

{ #category : 'fluent interface' }
RsJsonMultiSetValues >> key: key path: path value: value [
	"Add a key-path-value triplet to the batch"
	params add: { key. path. value }.
	^ self
]

{ #category : 'accessing' }
RsJsonMultiSetValues >> params [
	"Return the collection of parameter triplets"
	^ params
]