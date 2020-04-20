private commands
writeBytes: bytes to: aSocketStream
	aSocketStream nextPutAll: bytes.
	aSocketStream nextPutAll: #[13 10].