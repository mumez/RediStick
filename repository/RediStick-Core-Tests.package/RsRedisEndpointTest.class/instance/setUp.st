running
setUp
	stick := RsRediStick targetUrl: self urlForTest.
	stick onError: [ :e | Transcript printOn: e ].
	stick beSticky.
	stick connect