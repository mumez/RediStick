running
setUp
	super setUp.
	redisHashDictionary := Dictionary
		with: 'fieldA' -> 'valueA'
		with: 'fieldB' -> 'valueB'.
	stick := RsRediStick targetUrl: self urlForTest.
	stick beSticky.
	stick connect.
	self sendGoodPassword.
	(stick status ~= SkStickStatus connected
		or: [ stick status ~= SkStickStatus connecting ])
		ifFalse: [ self error: 'there is no redis server' ]