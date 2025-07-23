Class {
	#name : 'RsStreamInfo',
	#superclass : 'RsStreamObject',
	#instVars : [
		'length',
		'radixTreeKeys',
		'radixTreeNodes',
		'groups',
		'lastGeneratedId',
		'maxDeletedEntryId',
		'entriesAdded',
		'firstEntry',
		'lastEntry',
		'recordedFirstEntryId',
		'entries'
	],
	#category : 'RediStick-Stream',
	#package : 'RediStick-Stream'
}

{ #category : 'accessing' }
RsStreamInfo >> entries [

	^ entries
]

{ #category : 'accessing' }
RsStreamInfo >> entries: anObject [

	entries := anObject
]

{ #category : 'accessing' }
RsStreamInfo >> entriesAdded [

	^ entriesAdded
]

{ #category : 'accessing' }
RsStreamInfo >> entriesAdded: anObject [

	entriesAdded := anObject
]

{ #category : 'accessing' }
RsStreamInfo >> firstEntry [

	^ firstEntry
]

{ #category : 'accessing' }
RsStreamInfo >> firstEntry: anObject [

	firstEntry := anObject
]

{ #category : 'accessing' }
RsStreamInfo >> groups [

	^ groups
]

{ #category : 'accessing' }
RsStreamInfo >> groups: anObject [

	groups := anObject
]

{ #category : 'initialization' }
RsStreamInfo >> initEntries: value [
	| ents |
	ents := value collect: [ :each |
		        RsStreamEntry fromOrderedCollection: each ].
	^ self entries: ents
]

{ #category : 'initialization' }
RsStreamInfo >> initFromOrderedCollection: rawValues [
	rawValues ifNil: [ ^ self ].
	rawValues pairsDo: [ :key :value | self initVariableAt: key value: value ]
]

{ #category : 'initialization' }
RsStreamInfo >> initGroups: value [
	| grps |
	grps := value isInteger
		        ifTrue: [ value ]
		        ifFalse: [
			        value collect: [ :each |
				        RsStreamGroupInfo fromOrderedCollection: each ] ].
	^ self groups: grps
]

{ #category : 'initialization' }
RsStreamInfo >> initVariableAt: key value: value [
	key = 'length' ifTrue: [ ^ self length: value ].
	key = 'radix-tree-keys' ifTrue: [ ^ self radixTreeKeys: value ].
	key = 'radix-tree-nodes' ifTrue: [ ^ self radixTreeNodes: value ].
	key = 'last-generated-id' ifTrue: [ ^ self lastGeneratedId: value ].
	key = 'max-deleted-entry-id' ifTrue: [
		^ self maxDeletedEntryId: value ].
	key = 'entries-added' ifTrue: [ ^ self entriesAdded: value ].
	key = 'groups' ifTrue: [ ^ self initGroups: value].
	(key = 'first-entry' and: [value notNil]) ifTrue: [ ^ self firstEntry: (RsStreamEntry fromOrderedCollection: value) ].
	(key = 'last-entry' and: [value notNil]) ifTrue: [ ^ self lastEntry: (RsStreamEntry fromOrderedCollection: value) ].
	key = 'recorded-first-entry-id' ifTrue: [ ^ self recordedFirstEntryId: value ].
	key = 'entries' ifTrue: [ ^ self initEntries: value ].
]

{ #category : 'testing' }
RsStreamInfo >> isFull [
	^ self entries notNil
]

{ #category : 'accessing' }
RsStreamInfo >> lastEntry [

	^ lastEntry
]

{ #category : 'accessing' }
RsStreamInfo >> lastEntry: anObject [

	lastEntry := anObject
]

{ #category : 'accessing' }
RsStreamInfo >> lastGeneratedId [

	^ lastGeneratedId
]

{ #category : 'accessing' }
RsStreamInfo >> lastGeneratedId: anObject [

	lastGeneratedId := anObject
]

{ #category : 'accessing' }
RsStreamInfo >> length [

	^ length
]

{ #category : 'accessing' }
RsStreamInfo >> length: anObject [

	length := anObject
]

{ #category : 'accessing' }
RsStreamInfo >> maxDeletedEntryId [

	^ maxDeletedEntryId
]

{ #category : 'accessing' }
RsStreamInfo >> maxDeletedEntryId: anObject [

	maxDeletedEntryId := anObject
]

{ #category : 'printing' }
RsStreamInfo >> printOn: aStream [
    aStream nextPutAll: 'length: '.
    self length printOn: aStream.
    aStream cr; nextPutAll: 'radixTreeKeys: '.
    self radixTreeKeys printOn: aStream.
    aStream cr; nextPutAll: 'radixTreeNodes: '.
    self radixTreeNodes printOn: aStream.
    aStream cr; nextPutAll: 'groups: '.
    self groups printOn: aStream.
    aStream cr; nextPutAll: 'lastGeneratedId: '.
    self lastGeneratedId printOn: aStream.
    aStream cr; nextPutAll: 'maxDeletedEntryId: '.
    self maxDeletedEntryId printOn: aStream.
    aStream cr; nextPutAll: 'entriesAdded: '.
    self entriesAdded printOn: aStream.
    aStream cr; nextPutAll: 'firstEntry: '.
    self firstEntry printOn: aStream.
    aStream cr; nextPutAll: 'lastEntry: '.
    self lastEntry printOn: aStream.
    aStream cr; nextPutAll: 'recordedFirstEntryId: '.
    self recordedFirstEntryId printOn: aStream.
    aStream cr; nextPutAll: 'entries: '.
    self entries printOn: aStream.
]

{ #category : 'accessing' }
RsStreamInfo >> radixTreeKeys [

	^ radixTreeKeys
]

{ #category : 'accessing' }
RsStreamInfo >> radixTreeKeys: anObject [

	radixTreeKeys := anObject
]

{ #category : 'accessing' }
RsStreamInfo >> radixTreeNodes [

	^ radixTreeNodes
]

{ #category : 'accessing' }
RsStreamInfo >> radixTreeNodes: anObject [

	radixTreeNodes := anObject
]

{ #category : 'accessing' }
RsStreamInfo >> recordedFirstEntryId [

	^ recordedFirstEntryId
]

{ #category : 'accessing' }
RsStreamInfo >> recordedFirstEntryId: anObject [

	recordedFirstEntryId := anObject
]

{ #category : 'accessing' }
RsStreamInfo >> size [
	^ self length
]
