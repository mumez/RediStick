Class {
	#name : 'RsStreamIterator',
	#superclass : 'Object',
	#instVars : [
		'name',
		'stream',
		'fromId',
		'currentId',
		'isInclusive'
	],
	#category : 'RediStick-Stream-Objects',
	#package : 'RediStick-Stream-Objects'
}

{ #category : 'instance creation' }
RsStreamIterator class >> on: aRsStream [
	^ self new stream: aRsStream; yourself
]

{ #category : 'instance creation' }
RsStreamIterator class >> on: aRsStream from: fromId [
	^ (self on: aRsStream)
		  initFromId: fromId;
		  yourself
]

{ #category : 'instance creation' }
RsStreamIterator class >> on: aRsStream nextFrom: fromId [
	^ (self on: aRsStream)
		  initFromId: fromId;
		  initCurrentId: fromId;
		  yourself
]

{ #category : 'accessing' }
RsStreamIterator >> basicCurrentId [
	^ currentId 
]

{ #category : 'actions' }
RsStreamIterator >> by: step do: aBlock [
	^ self
		  by: step
		  do: aBlock
		  whileFalse: [ :entries :id | entries isEmpty ]
]

{ #category : 'actions' }
RsStreamIterator >> by: step do: aBlock whileFalse: endConditionBlock [
	| entries strm eachEnt chunkEnts |
	entries := self entriesFrom: self currentId count: step.
	strm := entries readStream.
	eachEnt := nil.
	chunkEnts := OrderedCollection new.
	[
	eachEnt := strm next.
	eachEnt ifNotNil: [ chunkEnts add: eachEnt ].
	eachEnt notNil and: [
		(endConditionBlock cull: chunkEnts cull: eachEnt) not ] ] whileTrue: [
		aBlock value: eachEnt.
		self currentId: eachEnt id ].
	(entries isEmpty or: [entries last id asStreamMessageId > self currentId]) ifTrue: [ ^ self ].
	self by: step do: aBlock whileFalse: endConditionBlock
]

{ #category : 'actions' }
RsStreamIterator >> collect: aBlock [
	| entries |
	entries := OrderedCollection new.
	self do: [ :each | entries add: (aBlock value: each) ].
	^ entries
]

{ #category : 'private' }
RsStreamIterator >> contentsFrom: entryId count: step [
	^ self stream contentsFrom: entryId count: step
]

{ #category : 'private' }
RsStreamIterator >> contentsNextFrom: entryId count: step [
	^ self stream contentsNextFrom: entryId count: step
]

{ #category : 'accessing' }
RsStreamIterator >> currentId [
	currentId ifNil: [ ^ self fallbackId ].
	^ currentId 
]

{ #category : 'accessing' }
RsStreamIterator >> currentId: anObject [

	currentId := anObject asStreamMessageId
]

{ #category : 'actions' }
RsStreamIterator >> do: aBlock [
	^ self by: self settings iterationReadChunkSize do: aBlock
]

{ #category : 'actions' }
RsStreamIterator >> do: aBlock whileFalse: endConditionBlock [
	^ self by: self settings iterationReadChunkSize do: aBlock whileFalse: endConditionBlock
]

{ #category : 'accessing' }
RsStreamIterator >> endpoint [
	^ self stream endpoint
]

{ #category : 'private' }
RsStreamIterator >> entriesFrom: entryId count: step [
	self isInclusive ifTrue: [ ^ self contentsFrom: entryId count: step ].
	^ self contentsNextFrom: entryId count: step
]

{ #category : 'private' }
RsStreamIterator >> fallbackId [
	^ self stream first
		  ifNotNil: [ :first | first id ]
		  ifNil: [ RsStreamMessageId zero ]
]

{ #category : 'accessing' }
RsStreamIterator >> fromId [

	^ fromId
]

{ #category : 'accessing' }
RsStreamIterator >> fromId: anObject [

	fromId := anObject
]

{ #category : 'accessing' }
RsStreamIterator >> fullName [
	^ String streamContents: [ :str |
		  str
			  nextPutAll: self streamName;
			  nextPut: $:;
			  nextPutAll: self name;
			  nextPut: $:;
			  nextPutAll: self currentId asString]
]

{ #category : 'private' }
RsStreamIterator >> generateName [
	^ UUID new asString
]

{ #category : 'initialization' }
RsStreamIterator >> initCurrentId: fromIdLikeThing [
	currentId := fromIdLikeThing ifNotNil: [ fromIdLikeThing asStreamMessageId ].
]

{ #category : 'initialization' }
RsStreamIterator >> initFromId: fromIdLikeThing [
	fromId := fromIdLikeThing ifNotNil: [ fromIdLikeThing asStreamMessageId ].
]

{ #category : 'testing' }
RsStreamIterator >> isInclusive [
	isInclusive ifNil: [ ^ currentId isNil ].
	^ isInclusive 
]

{ #category : 'accessing' }
RsStreamIterator >> isInclusive: aBoolean [
	isInclusive := aBoolean
]

{ #category : 'accessing' }
RsStreamIterator >> name [

	^ name ifNil: [ name := self generateName ]
]

{ #category : 'accessing' }
RsStreamIterator >> name: anObject [

	name := anObject
]

{ #category : 'private' }
RsStreamIterator >> nextAtMost: step after: entryId [
	^ self stream nextAtMost: step after: entryId
]

{ #category : 'actions' }
RsStreamIterator >> nextAtMost: step do: aBlock [
	| entries |
	entries := self nextAtMost: step after: self currentId.
	entries do: [ :each |
		aBlock value: each.
		self currentId: each id ]
]

{ #category : 'printing' }
RsStreamIterator >> printOn: aStream [
	aStream nextPutAll: self fullName
]

{ #category : 'converting' }
RsStreamIterator >> reversed [
	^ RsStreamReverseIterator on: self stream nextFrom: self basicCurrentId 
]

{ #category : 'accessing' }
RsStreamIterator >> settings [
	^ self stream settings
]

{ #category : 'accessing' }
RsStreamIterator >> stream [

	^ stream
]

{ #category : 'accessing' }
RsStreamIterator >> stream: anObject [

	stream := anObject
]

{ #category : 'accessing' }
RsStreamIterator >> streamName [
	^ self stream name
]
