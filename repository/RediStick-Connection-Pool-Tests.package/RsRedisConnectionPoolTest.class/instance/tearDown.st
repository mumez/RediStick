running
tearDown 
	connectionPool connectionDo: [:aRsRedis | aRsRedis endpoint flushAll ] at: self databaseName 