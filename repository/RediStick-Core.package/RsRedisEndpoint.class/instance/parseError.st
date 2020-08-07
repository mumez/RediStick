private replies
parseError
	| error |
	error := RsGenericError errorMessage: self parseSingleLine.
	error signal.
	^ nil