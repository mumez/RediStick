commands-server
shutdown
	self socketStream
		nextPutAll: 'SHUTDOWN';
		crlf;
		flush.
	self release