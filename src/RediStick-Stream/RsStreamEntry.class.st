Class {
	#name : 'RsStreamEntry',
	#superclass : 'RsStreamObject',
	#instVars : [
		'id',
		'fieldsAndValues',
		'acceptor'
	],
	#category : 'RediStick-Stream',
	#package : 'RediStick-Stream'
}

{ #category : 'actions' }
RsStreamEntry >> accept [
	^ self acceptor ifNotNil: [:acc | acc value: self]
]

{ #category : 'accessing' }
RsStreamEntry >> acceptor [
	^ acceptor 
]

{ #category : 'accessing' }
RsStreamEntry >> acceptor: aBlock [
	acceptor := aBlock
]

{ #category : 'accessing' }
RsStreamEntry >> content [
	^ self fieldAndValue
]

{ #category : 'accessing' }
RsStreamEntry >> contents [
	^ self fieldsAndValues 
]

{ #category : 'accessing' }
RsStreamEntry >> fieldAndValue [
	^ self fieldsAndValues first
]

{ #category : 'accessing' }
RsStreamEntry >> fieldAt: key [
	^ self fieldsAndValuesDict at: key ifAbsent: [  ]
]

{ #category : 'accessing' }
RsStreamEntry >> fieldKeys [
	^ self fieldsAndValues collect: [ :each | each key ]
]

{ #category : 'accessing' }
RsStreamEntry >> fieldsAndValues [

	^ fieldsAndValues
]

{ #category : 'accessing' }
RsStreamEntry >> fieldsAndValues: anObject [

	fieldsAndValues := anObject
]

{ #category : 'accessing' }
RsStreamEntry >> fieldsAndValuesDict [
	^ self fieldsAndValues inject: Dictionary new into: [ :sum :each  | 
		sum at: each key put: each value; yourself
	]
]

{ #category : 'accessing' }
RsStreamEntry >> id [

	^ id
]

{ #category : 'accessing' }
RsStreamEntry >> id: anObject [

	id := anObject
]

{ #category : 'initialization' }
RsStreamEntry >> initFromOrderedCollection: keyWithFieldsAndValues [
	self id: keyWithFieldsAndValues first.
	self fieldsAndValues: (keyWithFieldsAndValues last pairsCollect: [:k :v | k -> v]).
]

{ #category : 'printing' }
RsStreamEntry >> printOn: aStream [
	aStream nextPutAll: self id.
	aStream nextPutAll: ':'.
	self fieldsAndValues asArray printOn: aStream
]
