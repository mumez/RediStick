accessing
intervalSeconds
	intervalSeconds ifNil: [ intervalSeconds := self defaultIntervalSeconds ].
	^intervalSeconds