initialization
initFromOrderedCollection: rawValues
	self nextId: rawValues first.
	self initClaimedMessages: rawValues second.
	self deletedMessages: rawValues third