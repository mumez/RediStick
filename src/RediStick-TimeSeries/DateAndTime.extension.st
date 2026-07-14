Extension { #name : 'DateAndTime' }

{ #category : '*RediStick-TimeSeries' }
DateAndTime >> asRediStickUnixTimestampMillis [
	^ (self - DateAndTime epoch) asMilliSeconds
]
