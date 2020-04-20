private replies
parseReply
	| strm replyToken |
	strm := self socketStream ifNil: [ ^nil ].
	replyToken := [strm next] on: Error do: [:ex | (SkError kind: #CannotGetReply) signal].
	replyToken = 43 "$+ asInteger"
		ifTrue: [^ self parseSingleLine].
	replyToken = 58 "$: asInteger"
		ifTrue: [^ self parseInteger].
	replyToken = 36 "$$ asInteger"
		ifTrue: [^ self parseBulkReply].
	replyToken = 42 "$* asInteger"
		ifTrue: [^ self parseMultiBulkReply].
	replyToken = 45 "$- asInteger"
		ifTrue: [^ self parseError].
		
	(SkError kind: #InvalidReplyToken) signal