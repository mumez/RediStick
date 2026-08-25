Class {
	#name : 'RsTsFilter',
	#superclass : 'Object',
	#instVars : [
		'label',
		'operator',
		'value'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'instance creation' }
RsTsFilter class >> label: aLabel eq: aValue [
	^ self new setLabel: aLabel operator: '=' value: aValue asString
]

{ #category : 'instance creation' }
RsTsFilter class >> label: aLabel notEq: aValue [
	^ self new setLabel: aLabel operator: '!=' value: aValue asString
]

{ #category : 'instance creation' }
RsTsFilter class >> label: aLabel in: aCollection [
	^ self new setLabel: aLabel operator: '=' value: (self parenListFrom: aCollection)
]

{ #category : 'instance creation' }
RsTsFilter class >> label: aLabel notIn: aCollection [
	^ self new setLabel: aLabel operator: '!=' value: (self parenListFrom: aCollection)
]

{ #category : 'instance creation' }
RsTsFilter class >> hasLabel: aLabel [
	^ self new setLabel: aLabel operator: '!=' value: ''
]

{ #category : 'instance creation' }
RsTsFilter class >> noLabel: aLabel [
	^ self new setLabel: aLabel operator: '=' value: ''
]

{ #category : 'private' }
RsTsFilter class >> parenListFrom: aCollection [
	^ '(' , (',' join: (aCollection collect: [ :v | v asString ])) , ')'
]

{ #category : 'converting' }
RsTsFilter >> asString [
	^ self label , self operator , self value
]

{ #category : 'testing' }
RsTsFilter >> isEqualityMatcher [
	^ self operator = '=' and: [ self value notEmpty ]
]

{ #category : 'accessing' }
RsTsFilter >> label [
	^ label
]

{ #category : 'accessing' }
RsTsFilter >> label: aLabel [
	label := aLabel
]

{ #category : 'accessing' }
RsTsFilter >> operator [
	^ operator
]

{ #category : 'accessing' }
RsTsFilter >> operator: anOperator [
	operator := anOperator
]

{ #category : 'private' }
RsTsFilter >> setLabel: aLabel operator: anOperator value: aValue [
	self label: aLabel.
	self operator: anOperator.
	self value: aValue
]

{ #category : 'accessing' }
RsTsFilter >> value [
	^ value
]

{ #category : 'accessing' }
RsTsFilter >> value: aValue [
	value := aValue
]
