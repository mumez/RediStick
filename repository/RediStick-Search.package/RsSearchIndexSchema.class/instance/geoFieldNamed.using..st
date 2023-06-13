adding
geoFieldNamed: fieldName using: optionsBlock
	^ self addField: (self createFieldNamed: fieldName) geo using: optionsBlock.
	 