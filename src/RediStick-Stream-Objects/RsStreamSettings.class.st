Class {
	#name : 'RsStreamSettings',
	#superclass : 'SkSettings',
	#category : 'RediStick-Stream-Objects',
	#package : 'RediStick-Stream-Objects'
}

{ #category : 'accessing' }
RsStreamSettings >> claimMinIdleMilliseconds [
	^ self at: #claimMinIdleMilliseconds ifAbsentPut: [3600000]
]

{ #category : 'accessing' }
RsStreamSettings >> claimMinIdleMilliseconds: anInteger [
	self at: #claimMinIdleMilliseconds put: anInteger
]

{ #category : 'accessing' }
RsStreamSettings >> claimReadChunkSize [
	^ self at: #claimReadChunkSize ifAbsentPut: [20]
]

{ #category : 'accessing' }
RsStreamSettings >> claimReadChunkSize: anInteger [
	self at: #claimReadChunkSize put: anInteger
]

{ #category : 'accessing' }
RsStreamSettings >> iterationReadChunkSize [
	^ self at: #iterationReadChunkSize ifAbsentPut: [20]
]

{ #category : 'accessing' }
RsStreamSettings >> iterationReadChunkSize: anInteger [
	self at: #iterationReadChunkSize put: anInteger
]

{ #category : 'accessing' }
RsStreamSettings >> pollReadChunkSize [
	^ self at: #pollReadChunkSize ifAbsentPut: [20]
]

{ #category : 'accessing' }
RsStreamSettings >> pollReadChunkSize: anInteger [
	self at: #pollReadChunkSize put: anInteger
]

{ #category : 'accessing' }
RsStreamSettings >> targetUrl [
	^ self at: #targetUrl ifAbsentPut: ['sync://localhost:6379']
]

{ #category : 'accessing' }
RsStreamSettings >> targetUrl: aString [
	self at: #targetUrl put: aString
]

{ #category : 'accessing' }
RsStreamSettings >> waitMilliseconds [
	^ self at: #waitMilliseconds ifAbsentPut: [1000]
]

{ #category : 'accessing' }
RsStreamSettings >> waitMilliseconds: anInteger [
	self at: #waitMilliseconds put: anInteger
]
