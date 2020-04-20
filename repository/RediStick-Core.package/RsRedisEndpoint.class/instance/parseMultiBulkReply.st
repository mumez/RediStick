private replies
parseMultiBulkReply
	| count reply |
	count := self parseInteger.
	count = -1
		ifTrue: [^ nil].
	reply := OrderedCollection new.
	count
		timesRepeat: [reply add: self parseReply].
	^ reply