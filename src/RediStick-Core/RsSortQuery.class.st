Class {
	#name : 'RsSortQuery',
	#superclass : 'Object',
	#instVars : [
		'key',
		'by',
		'descending',
		'alpha',
		'get',
		'store',
		'start',
		'count',
		'mGet',
		'endpoint'
	],
	#category : 'RediStick-Core',
	#package : 'RediStick-Core'
}

{ #category : 'instance-creation' }
RsSortQuery class >> key: aKey on: endpoint [
	^ self new
		key: aKey;
		endpoint: endpoint;
		yourself
]

{ #category : 'sort-order' }
RsSortQuery >> alpha [
	alpha := true
]

{ #category : 'sort-filter' }
RsSortQuery >> by: aPattern [
	by := aPattern
]

{ #category : 'sort-order' }
RsSortQuery >> descending [
	descending := true
]

{ #category : 'accessing' }
RsSortQuery >> endpoint [
	^ endpoint
]

{ #category : 'accessing' }
RsSortQuery >> endpoint: anObject [
	endpoint := anObject
]

{ #category : 'actions' }
RsSortQuery >> execute [
	^self executeOn: self endpoint
]

{ #category : 'protected' }
RsSortQuery >> executeOn: aRedisEndpoint [
	| args |
	args := OrderedCollection new.
	by
		ifNotNil: [ args
				add: 'BY';
				add: by ].
	start
		ifNotNil: [ args
				add: 'LIMIT';
				add: start;
				add: count ].
	get
		ifNotNil: [ args
				add: 'GET';
				add: get ].
	mGet
		ifNotNil: [ mGet
				do: [ :ea | 
					args
						add: 'GET';
						add: ea ] ].
	descending ifNotNil: [ args add: 'DESC' ].
	alpha ifNotNil: [ args add: 'ALPHA' ].
	store
		ifNotNil: [ args
				add: 'STORE';
				add: store ].
	^ args isEmpty
		ifTrue: [ aRedisEndpoint sort: key ]
		ifFalse: [ aRedisEndpoint unifiedCommand: {'SORT'. key}, {args}]
]

{ #category : 'external-keys' }
RsSortQuery >> get: aPattern [
	get := aPattern
]

{ #category : 'accessing' }
RsSortQuery >> key: aKey [
	key := aKey
]

{ #category : 'sort-filter' }
RsSortQuery >> limit: aCount starting: startIndex [
	count := aCount.
	start := startIndex
]

{ #category : 'external-keys' }
RsSortQuery >> mGet: patterns [
	mGet := patterns
]

{ #category : 'result-storage' }
RsSortQuery >> store: destinationKey [
	store := destinationKey
]
