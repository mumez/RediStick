*RediStick-Stream
xRead: key id: id using: optionsBlock
	| keysAndValues messageDict |
	keysAndValues := { key -> id }.
	messageDict := self xReadKeysAndIds: keysAndValues using: optionsBlock.
	^ messageDict at: key ifAbsent: [ #() ]