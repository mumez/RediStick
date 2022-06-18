accessing
subscriberRedis
	^subscriberRedis ifNil: [ subscriberRedis := self createSubscriberRedis ]