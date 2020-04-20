commands-server
monitor: aStream 
	self socketStream nextPutAll: 'MONITOR';
		 crlf;
		 flush.
	[[[self socketStream atEnd]
		whileFalse: [aStream
				nextPutAll: self parseSingleLine;
				nextPutAll: String crlf;
				flush]]
		on: Error
		do: [:ex | aStream nextPutAll: 'Connection Closed';
				 nextPutAll: String crlf;
				 flush]] fork