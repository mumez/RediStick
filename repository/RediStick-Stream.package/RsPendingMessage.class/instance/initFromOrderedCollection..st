initialization
initFromOrderedCollection: rawValues
	self id: rawValues first.
	self consumerName: rawValues second.
	self millisecondsFromLastDelivery: rawValues third.
	self deliveredCount: rawValues last.