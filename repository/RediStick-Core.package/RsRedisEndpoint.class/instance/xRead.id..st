commands-stream
xRead: key id: id
	| keysAndValues |
	keysAndValues := { key -> id }.
	^ self xReadKeysAndIds: keysAndValues using: [ :opts | ]