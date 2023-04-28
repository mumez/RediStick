accessing
maxSubscriberRestorationRetries
	^ maxSubscriberRestorationRetries ifNil: [ maxSubscriberRestorationRetries := 3 ]