initialization
initFromOrderedCollection: keyWithFieldsAndValues
	self id: keyWithFieldsAndValues first.
	self fieldsAndValues: (keyWithFieldsAndValues last pairsCollect: [:k :v | k -> v]).