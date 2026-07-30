Class {
	#name : 'RsTsFilterBuilder',
	#superclass : 'Object',
	#instVars : [
		'filters'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'initialization' }
RsTsFilterBuilder >> initialize [
	super initialize.
	filters := OrderedCollection new
]

{ #category : 'accessing' }
RsTsFilterBuilder >> filters [
	^ filters asArray
]

{ #category : 'accessing' }
RsTsFilterBuilder >> filtersCollection [
	^ filters
]

{ #category : 'building' }
RsTsFilterBuilder >> label: aLabel eq: aValue [
	self filtersCollection add: (RsTsFilter label: aLabel eq: aValue).
	^ self
]

{ #category : 'building' }
RsTsFilterBuilder >> label: aLabel notEq: aValue [
	self filtersCollection add: (RsTsFilter label: aLabel notEq: aValue).
	^ self
]

{ #category : 'building' }
RsTsFilterBuilder >> label: aLabel in: aCollection [
	self filtersCollection add: (RsTsFilter label: aLabel in: aCollection).
	^ self
]

{ #category : 'building' }
RsTsFilterBuilder >> label: aLabel notIn: aCollection [
	self filtersCollection add: (RsTsFilter label: aLabel notIn: aCollection).
	^ self
]

{ #category : 'building' }
RsTsFilterBuilder >> hasLabel: aLabel [
	self filtersCollection add: (RsTsFilter hasLabel: aLabel).
	^ self
]

{ #category : 'building' }
RsTsFilterBuilder >> noLabel: aLabel [
	self filtersCollection add: (RsTsFilter noLabel: aLabel).
	^ self
]

{ #category : 'validation' }
RsTsFilterBuilder >> validate [
	self filters ifEmpty: [
		^ (RsError invalidArguments) signal: 'At least one filter expression is required' ].
	(self filters anySatisfy: [ :f | f isEqualityMatcher ]) ifFalse: [
		^ (RsError invalidArguments) signal:
			'At least one filter expression with a syntax label=value or label=(value1,value2,...) is required.' ]
]
