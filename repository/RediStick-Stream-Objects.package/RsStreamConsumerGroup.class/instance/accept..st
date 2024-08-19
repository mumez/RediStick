reading
accept: aStreamEntry
	| msgId |
	msgId := aStreamEntry asStreamMessageId. 
	self endpoint xAck: self streamName group: self name id: msgId.
	currentId := msgId