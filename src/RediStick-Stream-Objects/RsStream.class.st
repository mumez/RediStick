Class {
	#name : 'RsStream',
	#superclass : 'Object',
	#instVars : [
		'stick',
		'settings',
		'name',
		'autoCreate'
	],
	#category : 'RediStick-Stream-Objects',
	#package : 'RediStick-Stream-Objects'
}

{ #category : 'instance creation' }
RsStream class >> named: streamName [
	^ self new name: streamName; yourself
]

{ #category : 'instance creation' }
RsStream class >> on: aRediStick [
	^ self new stick: aRediStick
]

{ #category : 'adding' }
RsStream >> << keyValuesOrAssociation [
	keyValuesOrAssociation isAssociation
		ifTrue: [ self nextPut: keyValuesOrAssociation ]
		ifFalse: [ self nextPutAssociations: keyValuesOrAssociation ]
]

{ #category : 'accessing' }
RsStream >> autoCreate [

	^ autoCreate ifNil: [ autoCreate := true ]
]

{ #category : 'accessing' }
RsStream >> autoCreate: anObject [

	autoCreate := anObject
]

{ #category : 'deleting' }
RsStream >> beEmpty [
	self trimTo: 0
]

{ #category : 'deleting' }
RsStream >> beEmptyAndReset [
	self beEmpty.
	self setLastMessageId: RsStreamMessageId epoch
]

{ #category : 'reading' }
RsStream >> comingAtMost: count [ 
	^ self comingAtMost: count waitFor: self settings waitMilliseconds
]

{ #category : 'reading' }
RsStream >> comingAtMost: count waitFor: milliseconds [
	^ self endpoint
		  xRead: self name
		  id: RsStreamMessageId newest
		  blocking: milliseconds
		  count: count
]

{ #category : 'factory' }
RsStream >> consumerGroupClass [
	^ RsStreamConsumerGroup
]

{ #category : 'consumer-groups' }
RsStream >> consumerGroupNamed: groupName [
	^ (self consumerGroupClass named: groupName on: self) assureExistence 
]

{ #category : 'consumer-groups' }
RsStream >> consumerGroupNamed: groupName fromId: fromId [
	| consumerGroup |
	consumerGroup := self consumerGroupClass named: groupName on: self from: fromId.
	consumerGroup assureExistence.
	^ consumerGroup
]

{ #category : 'consumer-groups' }
RsStream >> consumerGroupsInfo [
	^ self endpoint xInfoGroups: self name
]

{ #category : 'reading' }
RsStream >> contentAt: aMessageId [
	| conts |
	conts :=  self contentsFrom: aMessageId to: aMessageId.
	conts ifEmpty: [ ^ nil ].
	^ conts first
]

{ #category : 'reading' }
RsStream >> contents [
	^ self contentsFrom: RsStreamMessageId min to: RsStreamMessageId max
]

{ #category : 'reading' }
RsStream >> contentsFrom: fromMessageId [ 
	^ self contentsFrom: fromMessageId to: RsStreamMessageId max
]

{ #category : 'reading' }
RsStream >> contentsFrom: fromMessageId count: count [
	^ self endpoint xRange: self name from: fromMessageId count: count
]

{ #category : 'reading' }
RsStream >> contentsFrom: fromMessageId to: toMessageId [
	^ self endpoint xRange: self name start: fromMessageId end: toMessageId 
]

{ #category : 'reading' }
RsStream >> contentsNextFrom: fromMessageId count: count [
	^ self endpoint xRange: self name nextFrom: fromMessageId count: count
]

{ #category : 'reading' }
RsStream >> contentsReversed [
	^ self contentsReversedFrom: RsStreamMessageId max to: RsStreamMessageId min
]

{ #category : 'reading' }
RsStream >> contentsReversedFrom: fromMessageId [
	^ self contentsReversedFrom: fromMessageId to: RsStreamMessageId min
]

{ #category : 'reading' }
RsStream >> contentsReversedFrom: fromMessageId count: count [
	^ self endpoint xRevRange: self name from: fromMessageId count: count
]

{ #category : 'reading' }
RsStream >> contentsReversedFrom: fromMessageId to: toMessageId [
	^ self endpoint xRevRange: self name start: fromMessageId end: toMessageId 
]

{ #category : 'reading' }
RsStream >> contentsReversedNextFrom: fromMessageId count: count [
	^ self endpoint xRevRange: self name nextFrom: fromMessageId count: count
]

{ #category : 'factory' }
RsStream >> createStick [
	| newStick |
	newStick := RsRediStick targetUrl: self settings targetUrl.
	newStick beSticky.
	newStick connect.
	^ newStick
]

{ #category : 'deleting' }
RsStream >> deleteAt: streamMessageId [
	^ self endpoint xDel: self name id: streamMessageId
]

{ #category : 'deleting' }
RsStream >> deleteAtIds: streamMessageIds [
	^ self endpoint xDel: self name ids: streamMessageIds
]

{ #category : 'accessing' }
RsStream >> endpoint [
	^ self stick endpoint
]

{ #category : 'private' }
RsStream >> ensureAssociations: keyValuesOrAssociation [

	^ keyValuesOrAssociation isCollection
		  ifTrue: [ keyValuesOrAssociation ]
		  ifFalse: [ { keyValuesOrAssociation } ]
]

{ #category : 'reading' }
RsStream >> first [
	| elems |
	elems := self first: 1.
	^ elems ifNotEmpty: [ elems first ] ifEmpty: [  ]
]

{ #category : 'reading' }
RsStream >> first: count [
	^ self contentsFrom: RsStreamMessageId min count: count
]

{ #category : 'accessing-info' }
RsStream >> fullInfo [
	^ self endpoint xInfoStream: self name full: true
]

{ #category : 'accessing-info' }
RsStream >> info [
	^ self endpoint xInfoStream: self name
]

{ #category : 'iterating' }
RsStream >> iterator [
	^ self iteratorClass on: self
]

{ #category : 'factory' }
RsStream >> iteratorClass [
	^ RsStreamIterator 
]

{ #category : 'iterating' }
RsStream >> iteratorNextFrom: fromId [
	^ self iteratorClass on: self nextFrom: fromId
]

{ #category : 'iterating' }
RsStream >> iteratorNextFromFirst [
	^ self iteratorNextFrom: self first
]

{ #category : 'iterating' }
RsStream >> iteratorNextFromLast [
	^ self iteratorNextFrom: self last
]

{ #category : 'reading' }
RsStream >> last [
	"^ self endpoint xRead: self name id: RsStreamMessageId max"
	| elems |
	elems := self last: 1.
	^ elems ifNotEmpty: [ elems first ] ifEmpty: [  ]
]

{ #category : 'reading' }
RsStream >> last: count [
	^ (self contentsReversedFrom: RsStreamMessageId max count: count) reversed
]

{ #category : 'accessing' }
RsStream >> length [
	^ self endpoint xLen: self name
]

{ #category : 'accessing' }
RsStream >> name [
	name ifNil: [ name := 'stream-', self identityHash asString ].
	^ name
]

{ #category : 'accessing' }
RsStream >> name: anObject [

	name := anObject
]

{ #category : 'reading' }
RsStream >> nextAfter: latestMessageId waitFor: milliseconds [
	^ self nextAtMost: 1 after: latestMessageId waitFor: milliseconds
]

{ #category : 'reading' }
RsStream >> nextAtMost: count after: latestMessageId [
	^ self endpoint xRead: self name id: latestMessageId count: count
]

{ #category : 'reading' }
RsStream >> nextAtMost: count after: latestMessageId waitFor: milliseconds [
	^ self endpoint
		  xRead: self name
		  id: latestMessageId
		  blocking: milliseconds
		  count: count
]

{ #category : 'adding' }
RsStream >> nextPut: keyValuesOrAssociation [
	^ self nextPutAssociations: (self ensureAssociations: keyValuesOrAssociation)
]

{ #category : 'adding' }
RsStream >> nextPut: keyValuesOrAssociation at: streamMessageId [
	^ self nextPutAssociations: (self ensureAssociations: keyValuesOrAssociation) at: streamMessageId trimUsing: [:opts |]
]

{ #category : 'adding' }
RsStream >> nextPut: keyValuesOrAssociation trimUsing: optionsBlock [
	^ self nextPutAssociations: (self ensureAssociations: keyValuesOrAssociation) at: RsStreamMessageId autoGenerated trimUsing: optionsBlock
]

{ #category : 'adding' }
RsStream >> nextPutAll: keyValuesOrAssociations [
	^ keyValuesOrAssociations collect: [ :each | self nextPut: each ]
]

{ #category : 'adding' }
RsStream >> nextPutAssociations: keyValueAssocs [
	^ self nextPutAssociations: keyValueAssocs trimUsing: [:opts |]
]

{ #category : 'adding' }
RsStream >> nextPutAssociations: keyValueAssocs at: streamMessageId [
	^ self nextPutAssociations: keyValueAssocs at: streamMessageId trimUsing: [:opts |]
]

{ #category : 'adding' }
RsStream >> nextPutAssociations: keyValueAssocs at: streamMessageId trimUsing: optionsBlock [
	^ RsStreamMessageId fromStringOrNil: (self endpoint
			   xAdd: self name
			   createNotExists: self autoCreate
			   trimUsing: optionsBlock
			   id: streamMessageId
			   fieldsAndValues: keyValueAssocs)
]

{ #category : 'adding' }
RsStream >> nextPutAssociations: keyValueAssocs trimUsing: optionsBlock [
	^ self nextPutAssociations: keyValueAssocs at: RsStreamMessageId autoGenerated trimUsing: optionsBlock
]

{ #category : 'reading' }
RsStream >> pendingsAfter: latestMessageId [
	^ self endpoint xRead: self name id: latestMessageId
]

{ #category : 'factory' }
RsStream >> pollerClass [
	^ RsStreamPoller
]

{ #category : 'polling' }
RsStream >> pollerIncoming [
	^ self pollerClass on: self
]

{ #category : 'polling' }
RsStream >> pollerNextFrom: fromId [
	^ self pollerClass on: self nextFrom: fromId
]

{ #category : 'polling' }
RsStream >> pollerNextFromFirst [
	^ self pollerNextFrom: self first
]

{ #category : 'polling' }
RsStream >> pollerNextFromLast [
	^ self pollerNextFrom: self last
]

{ #category : 'reading' }
RsStream >> previousAtMost: count after: latestMessageId [
	^ self endpoint xRevRange: self name nextFrom: latestMessageId count: count
]

{ #category : 'iterating' }
RsStream >> reverseIterator [
	^ self iterator reversed
]

{ #category : 'copying' }
RsStream >> sameNamed [
	^ self class named: self name
]

{ #category : 'accessing' }
RsStream >> setLastMessageId: messageId [
	^ self endpoint xSet: self name lastId: messageId
]

{ #category : 'accessing' }
RsStream >> settings [

	^ settings ifNil: [ settings := RsStreamSettings default ]
]

{ #category : 'accessing' }
RsStream >> settings: anObject [

	settings := anObject
]

{ #category : 'accessing' }
RsStream >> stick [
	^ stick ifNil: [ stick := self createStick ]
]

{ #category : 'accessing' }
RsStream >> stick: aRediStick [
	stick := aRediStick
]

{ #category : 'trimming' }
RsStream >> trimLeastTo: maxLength [
	^ self endpoint xTrim: self name maxLenAtLeast: maxLength
]

{ #category : 'trimming' }
RsStream >> trimLowerThan: messageId [
	^ self endpoint xTrim: self name minId: messageId
]

{ #category : 'trimming' }
RsStream >> trimTo: maxLength [
	^ self endpoint xTrim: self name maxLen: maxLength
]

{ #category : 'trimming' }
RsStream >> trimUsing: optionsBlock [
	^ self endpoint xTrim: self name using: optionsBlock
]
