adding
tagFieldNamed: fieldName using: optionsBlock
	^ self addField: (self createFieldNamed: fieldName) tag using: optionsBlock.
	 