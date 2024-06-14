accessing
targetUrl
	^ self at: #targetUrl ifAbsentPut: ['sync://localhost:6379']