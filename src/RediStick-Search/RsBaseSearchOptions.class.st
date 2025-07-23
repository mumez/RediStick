Class {
	#name : 'RsBaseSearchOptions',
	#superclass : 'Object',
	#instVars : [
		'options',
		'optionsDict'
	],
	#category : 'RediStick-Search',
	#package : 'RediStick-Search'
}

{ #category : 'evaluating' }
RsBaseSearchOptions class >> in: aBlock [
	| inst |
	inst := self new.
	aBlock value: inst.
	^ inst
]

{ #category : 'generating' }
RsBaseSearchOptions >> createArgumentsOn: args [
	^ args addAll: self options
]

{ #category : 'accessing' }
RsBaseSearchOptions >> options [

	^ options ifNil: [ options := OrderedCollection new ].
]

{ #category : 'accessing' }
RsBaseSearchOptions >> options: anObject [

	options := anObject
]

{ #category : 'accessing' }
RsBaseSearchOptions >> optionsDict [
	^ optionsDict ifNil: [ optionsDict := Dictionary new ]
]

{ #category : 'accessing' }
RsBaseSearchOptions >> optionsDict: aDictionary [
	optionsDict := aDictionary
]
