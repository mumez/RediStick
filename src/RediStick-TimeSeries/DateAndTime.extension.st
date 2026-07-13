Extension { #name : 'DateAndTime' }

{ #category : '*RediStick-TimeSeries' }
DateAndTime >> asUnixTimestampValue [
	^ (self asUnixTime * 1000) truncated
]
