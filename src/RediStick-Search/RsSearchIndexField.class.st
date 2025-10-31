Class {
	#name : 'RsSearchIndexField',
	#superclass : 'Object',
	#instVars : [
		'name',
		'alias',
		'type',
		'options'
	],
	#category : 'RediStick-Search',
	#package : 'RediStick-Search'
}

{ #category : 'instance creation' }
RsSearchIndexField class >> geo: fieldName [
	^(self name: fieldName) geo
]

{ #category : 'instance creation' }
RsSearchIndexField class >> geoshape: fieldName [
	^(self name: fieldName) geoshape
]

{ #category : 'instance creation' }
RsSearchIndexField class >> geometry: fieldName [
	"Deprecated. Use #geoshape: instead. GEOMETRY type has been renamed to GEOSHAPE in the latest Redis Search API."
	^self geoshape: fieldName
]

{ #category : 'instance creation' }
RsSearchIndexField class >> name: fieldName [
	^self name: fieldName type: ''
]

{ #category : 'instance creation' }
RsSearchIndexField class >> name: fieldName alias: alias [
	^ self new
		  name: fieldName;
		  type: alias;
		  yourself
]

{ #category : 'instance creation' }
RsSearchIndexField class >> name: fieldName type: typeName [
	^ self new
		  name: fieldName;
		  type: typeName;
		  yourself
]

{ #category : 'instance creation' }
RsSearchIndexField class >> numeric: fieldName [
	^(self name: fieldName) numeric
]

{ #category : 'instance creation' }
RsSearchIndexField class >> tag: fieldName [
	^(self name: fieldName) tag
]

{ #category : 'instance creation' }
RsSearchIndexField class >> text: fieldName [
	^(self name: fieldName) text
]

{ #category : 'instance creation' }
RsSearchIndexField class >> vector: fieldName [
	^(self name: fieldName) vector
]

{ #category : 'accessing' }
RsSearchIndexField >> alias [

	^ alias ifNil: [ alias := '' ]
]

{ #category : 'accessing' }
RsSearchIndexField >> alias: anObject [

	alias := anObject
]

{ #category : 'actions' }
RsSearchIndexField >> caseSensitive [
	self options add: 'CASESENSITIVE'
]

{ #category : 'generating' }
RsSearchIndexField >> createArgumentsOn: args [
	args add: self name.
	self alias ifNotEmpty:[args add: ('AS ', self alias)].
	self type ifNotEmpty:[args add: self type].
	args addAll: self options.
	^ args
]

{ #category : 'actions-type' }
RsSearchIndexField >> geo [
	^self type: 'GEO'
]

{ #category : 'actions-type' }
RsSearchIndexField >> geoshape [
	^self type: 'GEOSHAPE'
]

{ #category : 'actions-type' }
RsSearchIndexField >> geometry [
	"Deprecated. Use #geoshape instead. GEOMETRY type has been renamed to GEOSHAPE in the latest Redis Search API."
	^self geoshape
]

{ #category : 'accessing' }
RsSearchIndexField >> name [

	^ name ifNil: [ name := '' ]
]

{ #category : 'accessing' }
RsSearchIndexField >> name: anObject [

	name := anObject
]

{ #category : 'actions' }
RsSearchIndexField >> indexEmpty [
	self options add: 'INDEXEMPTY'
]

{ #category : 'actions' }
RsSearchIndexField >> indexMissing [
	self options add: 'INDEXMISSING'
]

{ #category : 'actions' }
RsSearchIndexField >> noIndex [
	self options add: 'NOINDEX'
]

{ #category : 'actions' }
RsSearchIndexField >> noStem [
	self options add: 'NOSTEM'
]

{ #category : 'actions-type' }
RsSearchIndexField >> numeric [
	^self type: 'NUMERIC'
]

{ #category : 'accessing' }
RsSearchIndexField >> options [

	^ options ifNil: [ options := OrderedCollection new ]
]

{ #category : 'accessing' }
RsSearchIndexField >> options: anObject [

	options := anObject
]

{ #category : 'actions' }
RsSearchIndexField >> phonetic: phoneticMatcher [
	self options add: ('PHONETIC ', phoneticMatcher asString)
]

{ #category : 'actions' }
RsSearchIndexField >> separator: separator [
	self options add: ('SEPARATOR ', separator asString)
]

{ #category : 'actions' }
RsSearchIndexField >> sortable [
	self options add: 'SORTABLE'
]

{ #category : 'actions' }
RsSearchIndexField >> sortableByUnnormalizedForm [
	self sortable.
	self options add: 'UNF'
]

{ #category : 'actions-type' }
RsSearchIndexField >> tag [
	^self type: 'TAG'
]

{ #category : 'actions-type' }
RsSearchIndexField >> text [
	^self type: 'TEXT'
]

{ #category : 'accessing' }
RsSearchIndexField >> type [

	^ type ifNil: [ type := '' ]
]

{ #category : 'accessing' }
RsSearchIndexField >> type: anObject [

	type := anObject
]

{ #category : 'actions-type' }
RsSearchIndexField >> vector [
	^self type: 'VECTOR'
]

{ #category : 'actions' }
RsSearchIndexField >> weight: weight [
	self options add: ('WEIGHT ', weight asString)
]

{ #category : 'actions' }
RsSearchIndexField >> withSuffixTrie [ 
	self options add: 'WITHSUFFIXTRIE'
]
