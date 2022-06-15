running
tearDown
	stick endpoint flushDb.
	stick close.
	
	super tearDown