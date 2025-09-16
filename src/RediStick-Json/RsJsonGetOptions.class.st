Class {
	#name : 'RsJsonGetOptions',
	#superclass : 'Object',
	#instVars : [
		'indent',
		'newLine',
		'space'
	],
	#category : 'RediStick-Json',
	#package : 'RediStick-Json'
}

{ #category : 'converting' }
RsJsonGetOptions >> asArray [
	| opts |
	opts := {} asOrderedCollection.
	self indent ifNotNil: [ :op | opts addAll: {'INDENT'. op} ].
	self newLine ifNotNil: [ :op | opts addAll: {'NEWLINE'. op} ].
	self space ifNotNil: [ :op | opts addAll: {'SPACE'. op} ].
	^ opts asArray
]

{ #category : 'testing' }
RsJsonGetOptions >> hasPrettyFormattingOptions [
	^ self indent notNil or: [ self newLine notNil or: [ self space notNil ] ]
]

{ #category : 'accessing' }
RsJsonGetOptions >> indent [

	^ indent
]

{ #category : 'accessing' }
RsJsonGetOptions >> indent: anObject [

	indent := anObject
]

{ #category : 'accessing' }
RsJsonGetOptions >> newLine [

	^ newLine
]

{ #category : 'accessing' }
RsJsonGetOptions >> newLine: anObject [

	newLine := anObject
]

{ #category : 'accessing' }
RsJsonGetOptions >> space [

	^ space
]

{ #category : 'accessing' }
RsJsonGetOptions >> space: anObject [

	space := anObject
]
