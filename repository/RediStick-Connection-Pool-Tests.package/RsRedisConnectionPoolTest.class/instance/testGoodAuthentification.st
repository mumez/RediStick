tests
testGoodAuthentification
	self initializeConnectionPool.
	connectionPool userName: nil password: self goodPassword.
	self
		shouldnt: [ connectionPool
				connectionDo: [ :aRsRedis | aRsRedis endpoint ping ]
				at: self databaseName ]
		raise: RsGenericError