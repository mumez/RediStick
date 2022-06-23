accessing
targetUrl
	^ targetUrl ifNil: [ targetUrl := 'sync://localhost:6379' ].