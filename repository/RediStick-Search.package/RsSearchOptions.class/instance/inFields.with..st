instance creation
inFields: aCount with: fields
    self options
		addAll: {
				'INFIELDS'.
				aCount asString };
		addAll: fields.