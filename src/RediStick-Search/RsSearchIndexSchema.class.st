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
RsSearchIndexSchema >> geoshapeFieldNamed: fieldName [
	^ self geoshapeFieldNamed: fieldName using: [:opts|]
]

{ #category : 'adding' }
RsSearchIndexSchema >> geoshapeFieldNamed: fieldName using: optionsBlock [
	^ self addField: (self createFieldNamed: fieldName) geoshape using: optionsBlock.

]

{ #category : 'adding' }
RsSearchIndexSchema >> geometryFieldNamed: fieldName [
	"Deprecated. Use #geoshapeFieldNamed: instead. GEOMETRY type has been renamed to GEOSHAPE in the latest Redis Search API."
	^ self geoshapeFieldNamed: fieldName
]

{ #category : 'adding' }
RsSearchIndexSchema >> geometryFieldNamed: fieldName using: optionsBlock [
	"Deprecated. Use #geoshapeFieldNamed:using: instead. GEOMETRY type has been renamed to GEOSHAPE in the latest Redis Search API."
	^ self geoshapeFieldNamed: fieldName using: optionsBlock
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
