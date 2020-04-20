private-encoding
utf8BytesFromString: aString
	aString ifNil: [ ^nil ].
	^self portableUtil utf8BytesFromString: aString