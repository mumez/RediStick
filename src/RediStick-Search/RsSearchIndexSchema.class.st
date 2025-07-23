Class {
	#name : 'RsSearchIndexSchema',
	#superclass : 'Object',
	#instVars : [
		'fields'
	],
	#category : 'RediStick-Search',
	#package : 'RediStick-Search'
}

{ #category : 'instance creation' }
RsSearchIndexSchema class >> in: aBlock [
	| inst |
	inst := self new.
	aBlock value: inst.
	^ inst
]

{ #category : 'adding' }
RsSearchIndexSchema >> addField: aSearchIndexField [
	self fields add: aSearchIndexField 
]

{ #category : 'adding' }
RsSearchIndexSchema >> addField: field using: optionsBlock [
	optionsBlock value: field.
	self addField: field
]

{ #category : 'generating' }
RsSearchIndexSchema >> createArgumentsOn: args [
	args add: 'SCHEMA'.
	self fields do: [ :each |
		each createArgumentsOn: args.	
	].
	^ args
]

{ #category : 'factory' }
RsSearchIndexSchema >> createFieldNamed: fieldName [
	^self fieldClasss name: fieldName
]

{ #category : 'factory' }
RsSearchIndexSchema >> fieldClasss [
	^ RsSearchIndexField
]

{ #category : 'accessing' }
RsSearchIndexSchema >> fields [

	^ fields ifNil: [ fields := OrderedCollection new ]
]

{ #category : 'accessing' }
RsSearchIndexSchema >> fields: anObject [

	fields := anObject
]

{ #category : 'adding' }
RsSearchIndexSchema >> geoFieldNamed: fieldName [
	^ self geoFieldNamed: fieldName using: [:opts|]
]

{ #category : 'adding' }
RsSearchIndexSchema >> geoFieldNamed: fieldName using: optionsBlock [
	^ self addField: (self createFieldNamed: fieldName) geo using: optionsBlock.
	 
]

{ #category : 'adding' }
RsSearchIndexSchema >> geometryFieldNamed: fieldName [
	^ self geometryFieldNamed: fieldName using: [:opts|]
]

{ #category : 'adding' }
RsSearchIndexSchema >> geometryFieldNamed: fieldName using: optionsBlock [
	^ self addField: (self createFieldNamed: fieldName) geometry using: optionsBlock.
	 
]

{ #category : 'adding' }
RsSearchIndexSchema >> numericFieldNamed: fieldName [
	^ self numericFieldNamed: fieldName using: [:opts|]
]

{ #category : 'adding' }
RsSearchIndexSchema >> numericFieldNamed: fieldName using: optionsBlock [
	^ self addField: (self createFieldNamed: fieldName) numeric using: optionsBlock.
	 
]

{ #category : 'adding' }
RsSearchIndexSchema >> tagFieldNamed: fieldName [
	^ self tagFieldNamed: fieldName using: [:opts|]
]

{ #category : 'adding' }
RsSearchIndexSchema >> tagFieldNamed: fieldName using: optionsBlock [
	^ self addField: (self createFieldNamed: fieldName) tag using: optionsBlock.
	 
]

{ #category : 'adding' }
RsSearchIndexSchema >> textFieldNamed: fieldName [
	^ self textFieldNamed: fieldName using: [:opts|]
]

{ #category : 'adding' }
RsSearchIndexSchema >> textFieldNamed: fieldName using: optionsBlock [
	^ self addField: (self createFieldNamed: fieldName) text using: optionsBlock.
	 
]

{ #category : 'adding' }
RsSearchIndexSchema >> vectorFieldNamed: fieldName [
	^ self vectorFieldNamed: fieldName using: [:opts|]
]

{ #category : 'adding' }
RsSearchIndexSchema >> vectorFieldNamed: fieldName using: optionsBlock [
	^ self addField: (self createFieldNamed: fieldName) vector using: optionsBlock.
	 
]
