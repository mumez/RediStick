running
setUp
	super setUp.
	
	stick := RsRediStick targetUrl: self class urlString.
	stick beSticky.
	stick connect.
	stick endpoint select: self class dbIndex.