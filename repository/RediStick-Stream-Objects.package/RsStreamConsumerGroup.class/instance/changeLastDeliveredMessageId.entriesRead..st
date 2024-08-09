actions
changeLastDeliveredMessageId: aStreamMessageId entriesRead: entriesRead
	| newMessageId |
	newMessageId := aStreamMessageId asStreamMessageId.
	self stream xGroupSetId: self name group: self name id: newMessageId entriesRead: entriesRead.
	self initMessageId: newMessageId