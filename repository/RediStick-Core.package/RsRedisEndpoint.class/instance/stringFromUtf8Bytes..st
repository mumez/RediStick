private-encoding
stringFromUtf8Bytes: aByteArray
	aByteArray ifNil: [ ^nil ].
	^self portableUtil stringFromUtf8Bytes: aByteArray