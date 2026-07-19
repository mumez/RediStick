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
	^ '(' , ((aCollection collect: [ :v | v asString ]) fold: [ :a :b | a , ',' , b ]) , ')'
]

{ #category : 'converting' }
RsTsFilter >> asString [
	^ label , operator , value
]

{ #category : 'private' }
RsTsFilter >> setLabel: aLabel operator: anOperator value: aValue [
	label := aLabel.
	operator := anOperator.
	value := aValue
]
