private commands
writeString: aString
	| bytes strm |
	bytes := self utf8BytesFromString: aString.
	strm := self socketStream ifNil: [^self]..
	strm nextPutAll: bytes.
	strm nextPutAll: #[13 10]. "crlf"
	strm flush