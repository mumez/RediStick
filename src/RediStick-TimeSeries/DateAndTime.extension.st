Extension { #name : 'DateAndTime' }

{ #category : '*RediStick-TimeSeries' }
DateAndTime >> asRediStickUnixTimestampMillis [
	^ ((self offset: Duration zero) - self class unixEpoch) asMilliSeconds
]
