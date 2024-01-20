initialization
initConsumersFrom: consumerRawValues
	| consumersDict |
	consumersDict := Dictionary new.
	consumerRawValues do: [ :each |
		consumersDict at: each first put: each last asInteger ].
	self consumers: consumersDict