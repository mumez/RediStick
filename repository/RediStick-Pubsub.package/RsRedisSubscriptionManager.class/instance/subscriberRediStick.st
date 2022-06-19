accessing
subscriberRediStick
	^subscriberRediStick ifNil: [ subscriberRediStick := self createSubscriberRediStick ]