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

{ #category : 'private' }
RsRedisTestCase >> redisVersion [
	"Answer the connected server's version as an Array of integers, e.g. #(8 4 0)"

	| line |
	line := stick endpoint info lines
		        detect: [ :each | each beginsWith: 'redis_version:' ]
		        ifNone: [ ^ #(  ) ].
	^ ((line allButFirst: 'redis_version:' size) trimBoth substrings: '.')
		  collect: [ :each | each asInteger ifNil: [ 0 ] ]
]

{ #category : 'private' }
RsRedisTestCase >> redisVersion: actualVersion isAtLeast: requiredVersion [
	"Compare version Arrays such as #(8 4 0); missing parts count as 0"

	1 to: (actualVersion size max: requiredVersion size) do: [ :index |
		| actual required |
		actual := index <= actualVersion size
			          ifTrue: [ actualVersion at: index ]
			          ifFalse: [ 0 ].
		required := index <= requiredVersion size
			            ifTrue: [ requiredVersion at: index ]
			            ifFalse: [ 0 ].
		actual = required ifFalse: [ ^ actual > required ] ].
	^ true
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
RsRedisTestCase >> skipUnlessRedisVersionAtLeast: requiredVersion [
	"Skip the current test when the server is older than requiredVersion, e.g. #(8 4)"

	(self redisVersion: self redisVersion isAtLeast: requiredVersion) ifFalse: [
		self skip: 'Requires Redis ' , ((requiredVersion collect: [ :each | each printString ]) joinUsing: '.') , ' or later' ]
]

{ #category : 'running' }
RsRedisTestCase >> tearDown [
	stick endpoint flushDb.
	stick close.
	
	super tearDown
]
