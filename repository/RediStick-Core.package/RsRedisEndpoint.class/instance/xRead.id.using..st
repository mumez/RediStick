commands-stream
xRead: key id: id using: optionsBlock
	| keysAndValues |
	keysAndValues := { key -> id }.
	^ self xReadKeysAndIds: keysAndValues using: optionsBlock