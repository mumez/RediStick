adding
geometryFieldNamed: fieldName using: optionsBlock
	^ self addField: (self createFieldNamed: fieldName) geometry using: optionsBlock.
	 