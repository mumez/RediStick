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

{ #category : 'building' }
RsTsFilterBuilder >> label: aLabel eq: aValue [
	filters add: (RsTsFilter label: aLabel eq: aValue).
	^ self
]

{ #category : 'building' }
RsTsFilterBuilder >> label: aLabel notEq: aValue [
	filters add: (RsTsFilter label: aLabel notEq: aValue).
	^ self
]

{ #category : 'building' }
RsTsFilterBuilder >> label: aLabel in: aCollection [
	filters add: (RsTsFilter label: aLabel in: aCollection).
	^ self
]

{ #category : 'building' }
RsTsFilterBuilder >> label: aLabel notIn: aCollection [
	filters add: (RsTsFilter label: aLabel notIn: aCollection).
	^ self
]

{ #category : 'building' }
RsTsFilterBuilder >> hasLabel: aLabel [
	filters add: (RsTsFilter hasLabel: aLabel).
	^ self
]

{ #category : 'building' }
RsTsFilterBuilder >> noLabel: aLabel [
	filters add: (RsTsFilter noLabel: aLabel).
	^ self
]
