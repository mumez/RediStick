Class {
	#name : 'RsRedisConnectionPoolTest',
	#superclass : 'TestCase',
	#instVars : [
		'redis',
		'connectionPool'
	],
	#category : 'RediStick-Tests',
	#package : 'RediStick-Tests'
}

{ #category : 'running' }
RsRedisConnectionPoolTest >> setUp [
	super setUp.
	
	redis := RsRedisProxy of: #test.
	connectionPool := RsRedisConnectionPool new. "For testing, do not user #default"
	connectionPool primaryUrl: RsRedisTestCase urlString.
	redis connectionPool: connectionPool.
]

{ #category : 'running' }
RsRedisConnectionPoolTest >> tearDown [
	connectionPool releaseConnections.
	
	super tearDown.
]

{ #category : 'tests' }
RsRedisConnectionPoolTest >> testPutGetWithConnectionPool [
	| done longPadding kvsProc1 kvsProc2 kvsProc3 kvsProc4 times |
	self timeLimit: 120 seconds.
	done := Semaphore new.
	longPadding := String new: 1024*1024*5 withAll: $a.
	times := 50.
	kvsProc1 := [ 
	times timesRepeat: [ | key rand |
		5 atRandom milliSeconds wait.
		rand := (1024*1024 to: longPadding size) atRandom.
		key := (1 to: 20) atRandom asString.
		redis at: 'test:', key put: ('val:', key, '!', (Time millisecondClockValue asString), (longPadding copyFrom: 1 to: rand)).
		Processor yield.
	 ].
	done signal.
	].

	kvsProc2 := [ 
	times timesRepeat: [ | key rand |
		5 atRandom milliSeconds wait.
		rand := (2048 to: longPadding size) atRandom.
		key := (1 to: 20) atRandom asString.
		redis at: 'test:', key put: ('val:', key, '!', (Time millisecondClockValue asString), (longPadding copyFrom: 1 to: rand)).
		Processor yield.
	 ].
	done signal.
	].

	kvsProc3 := [ 
	times timesRepeat: [ | key val |
		5 atRandom milliSeconds wait.
		key := (1 to: 20) atRandom asString.
		val := redis at: 'test:', key.
		val ifNotNil: [ | result |
			result := (val readStream upTo: $!) = ('val:', key).
			self assert: result.
		 ].
		Processor yield.
	 ].
	done signal.
	].

	kvsProc4 := [ 
	times timesRepeat: [ | key val |
		5 atRandom milliSeconds wait.
		key := (1 to: 20) atRandom asString.
		val := redis at: 'test:', key.
		val ifNotNil: [ | result |
			result := (val readStream upTo: $!) = ('val:', key).
			self assert: result.
		 ].
		Processor yield.
	 ].
	done signal.
	].

	kvsProc1 fork.
	kvsProc2 fork.
	kvsProc3 fork. 
	kvsProc4 fork. 
	done wait; wait; wait; wait.
	
	1 to: 20 do: [ :each | redis deleteKey: 'test:', each asString].

]
