running
setUp
	super setUp.
	stick := RsRediStick targetUrl: self urlForTest.
	stick onError: [ :e | Transcript printOn: e ].
	stick beSticky.
	stick connect.
	(stick status ~= SkStickStatus connected
		or: [ stick status ~= SkStickStatus connecting ])
		ifFalse: [ self error: 'there is no redis server' ]