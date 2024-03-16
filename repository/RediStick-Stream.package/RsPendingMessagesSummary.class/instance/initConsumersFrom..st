initialization
initConsumersFrom: consumerRawValues
	| consumersDict |
	consumersDict := Dictionary new.
	consumerRawValues ifNotNil: [ :rawValues |
		rawValues do: [ :each |
			consumersDict at: each first put: each last asInteger ] ].
	self consumers: consumersDict