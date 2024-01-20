initialization
initFromOrderedCollection: rawValues
	self size: rawValues first.
	self minId: rawValues second.
	self maxId: rawValues third.
	self initConsumersFrom: rawValues last.