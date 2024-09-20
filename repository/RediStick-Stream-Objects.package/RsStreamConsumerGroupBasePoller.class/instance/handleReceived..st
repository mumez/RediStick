handling
handleReceived: receivedEntry
	super handleReceived: receivedEntry.
	self shouldDeleteEntryAfterAcceptance ifTrue: [ self stream deleteAt: receivedEntry id ]