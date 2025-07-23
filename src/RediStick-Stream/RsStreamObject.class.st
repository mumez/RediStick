Class {
	#name : 'RsStreamObject',
	#superclass : 'Object',
	#category : 'RediStick-Stream',
	#package : 'RediStick-Stream'
}

{ #category : 'instance creation' }
RsStreamObject class >> fromOrderedCollection: values [
	| inst |
	inst := self new.
	inst initFromOrderedCollection: values.
	^ inst
]

{ #category : 'initialization' }
RsStreamObject >> initFromOrderedCollection: rawValues [
	self subclassResponsibility 
]
