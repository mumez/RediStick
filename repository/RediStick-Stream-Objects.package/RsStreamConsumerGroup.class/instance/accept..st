reading
accept: aStreamEntry
	self endpoint xAck: self streamName group: self name id: aStreamEntry asStreamMessageId 