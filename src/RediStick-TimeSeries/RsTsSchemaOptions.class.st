Class {
	#name : 'RsTsSchemaOptions',
	#superclass : 'RsTsOptions',
	#instVars : [
		'duplicatePolicy'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'accessing' }
RsTsSchemaOptions >> duplicatePolicy [
	^ duplicatePolicy
]

{ #category : 'accessing' }
RsTsSchemaOptions >> duplicatePolicy: aPolicy [
	duplicatePolicy := aPolicy
]

{ #category : 'shortcuts-duplicatePolicy' }
RsTsSchemaOptions >> duplicatePolicyBlock [
	self duplicatePolicy: 'BLOCK'
]

{ #category : 'shortcuts-duplicatePolicy' }
RsTsSchemaOptions >> duplicatePolicyFirst [
	self duplicatePolicy: 'FIRST'
]

{ #category : 'shortcuts-duplicatePolicy' }
RsTsSchemaOptions >> duplicatePolicyLast [
	self duplicatePolicy: 'LAST'
]

{ #category : 'shortcuts-duplicatePolicy' }
RsTsSchemaOptions >> duplicatePolicyMax [
	self duplicatePolicy: 'MAX'
]

{ #category : 'shortcuts-duplicatePolicy' }
RsTsSchemaOptions >> duplicatePolicyMin [
	self duplicatePolicy: 'MIN'
]

{ #category : 'shortcuts-duplicatePolicy' }
RsTsSchemaOptions >> duplicatePolicySum [
	self duplicatePolicy: 'SUM'
]

{ #category : 'converting' }
RsTsSchemaOptions >> asArray [
	| opts |
	opts := super asArray asOrderedCollection.
	self duplicatePolicy ifNotNil: [ :op | opts addAll: { 'DUPLICATE_POLICY'. op } ].
	^ opts asArray
]
