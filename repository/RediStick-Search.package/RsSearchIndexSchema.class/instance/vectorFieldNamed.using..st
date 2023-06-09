adding
vectorFieldNamed: fieldName using: optionsBlock
	^ self addField: (self createFieldNamed: fieldName) vector using: optionsBlock.
	 