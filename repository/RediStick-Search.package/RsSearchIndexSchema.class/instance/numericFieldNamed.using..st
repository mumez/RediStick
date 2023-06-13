adding
numericFieldNamed: fieldName using: optionsBlock
	^ self addField: (self createFieldNamed: fieldName) numeric using: optionsBlock.
	 