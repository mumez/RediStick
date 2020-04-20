private commands
writeUnifiedCommand: args
	| strm |
	strm := self socketStream ifNil: [^self].
	strm nextPut: $* asInteger.
	self writeBytes: args size asString asByteArray to: strm.
	args
		do: [ :ea | 
			| bytes |
			bytes := (self utf8BytesFromString: ea asString).
			strm nextPut: $$ asInteger.
			self writeBytes: bytes size asString asByteArray to: strm.
			self writeBytes: bytes to: strm].
	strm flush