Class {
	#name : 'RsRedisStreamBaseTestCase',
	#superclass : 'RsRedisTestCase',
	#category : 'RediStick-Stream-Objects-Tests',
	#package : 'RediStick-Stream-Objects-Tests'
}

{ #category : 'factory' }
RsRedisStreamBaseTestCase >> newStreamNamed: streamName [
	| strm |
	strm := RsStream new.
	strm name: streamName.
	strm autoCreate.
	^ strm
]
