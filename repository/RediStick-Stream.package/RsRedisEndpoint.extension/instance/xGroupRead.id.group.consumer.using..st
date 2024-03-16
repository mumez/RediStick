*RediStick-Stream
xGroupRead: key id: id group: group consumer: consumer using: optionsBlock
	| keysAndValues messageDict |
	keysAndValues := { key -> id }.
	messageDict := self xGroupReadKeysAndIds: keysAndValues group: group consumer: consumer using: optionsBlock.
	^ messageDict at: key ifAbsent: [ #() ]