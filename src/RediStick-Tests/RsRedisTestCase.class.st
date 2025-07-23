Class {
	#name : 'RsRedisTestCase',
	#superclass : 'TestCase',
	#instVars : [
		'stick'
	],
	#classVars : [
		'DbIndex',
		'UrlString'
	],
	#category : 'RediStick-Tests',
	#package : 'RediStick-Tests'
}

{ #category : 'accessing' }
RsRedisTestCase class >> dbIndex [

	^ DbIndex
]

{ #category : 'accessing' }
RsRedisTestCase class >> dbIndex: anObject [

	DbIndex := anObject
]

{ #category : 'class initialization' }
RsRedisTestCase class >> initialize [
	"Before testing, you should set uriString to connect to redis"
	UrlString := 'sync://localhost:6379'.
	DbIndex := 15
]

{ #category : 'accessing' }
RsRedisTestCase class >> urlString [

	^ UrlString
]

{ #category : 'accessing' }
RsRedisTestCase class >> urlString: anObject [

	UrlString := anObject
]

{ #category : 'private' }
RsRedisTestCase >> newDateAndTimeValue [
	^ DateAndTime now asString
]

{ #category : 'running' }
RsRedisTestCase >> setUp [
	super setUp.
	
	stick := RsRediStick targetUrl: self class urlString.
	stick beSticky.
	stick connect.
	stick endpoint select: self class dbIndex.
]

{ #category : 'running' }
RsRedisTestCase >> tearDown [
	stick endpoint flushDb.
	stick close.
	
	super tearDown
]
