Class {
	#name : 'RsStreamReverseIterator',
	#superclass : 'RsStreamIterator',
	#category : 'RediStick-Stream-Objects',
	#package : 'RediStick-Stream-Objects'
}

{ #category : 'private' }
RsStreamReverseIterator >> contentsFrom: entryId count: step [
	^ self stream contentsReversedFrom: entryId count: step
]

{ #category : 'private' }
RsStreamReverseIterator >> contentsNextFrom: entryId count: step [
	^ self stream contentsReversedNextFrom: entryId count: step
]

{ #category : 'private' }
RsStreamReverseIterator >> fallbackId [
	^ self stream last id
]

{ #category : 'private' }
RsStreamReverseIterator >> nextAtMost: step after: entryId [
	^ self stream previousAtMost: step after: entryId
]

{ #category : 'converting' }
RsStreamReverseIterator >> reversed [
	^ RsStreamIterator on: self stream nextFrom: self basicCurrentId 
]
