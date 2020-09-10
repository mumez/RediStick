running
initializeStick
	stick := RsRediStick targetUrl: self urlForTest.
	stick beSticky.
	stick connect