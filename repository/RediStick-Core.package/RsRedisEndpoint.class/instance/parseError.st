private replies
parseError
	| error |
	error := SkError kind: #ParseError.
	error otherInfo at: 'message' put: self parseSingleLine.
	error signal.
	^ nil