factory
newStreamNamed: streamName
	| strm |
	strm := RsStream new.
	strm name: streamName.
	strm autoCreate.
	^ strm