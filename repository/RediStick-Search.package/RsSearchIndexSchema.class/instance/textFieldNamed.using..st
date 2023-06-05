adding
textFieldNamed: fieldName using: optionsBlock
	^ self addField: (self createFieldNamed: fieldName) text using: optionsBlock.
	 