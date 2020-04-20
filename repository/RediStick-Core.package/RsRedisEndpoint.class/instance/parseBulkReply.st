private replies
parseBulkReply
	| length reply |
	length := self parseInteger.
	length = -1
		ifTrue: [ reply := nil ]
		ifFalse: [ 
			reply := self socketStream next: length.
			self socketStream next: 2 "skip separators"].
	^ self stringFromUtf8Bytes: reply