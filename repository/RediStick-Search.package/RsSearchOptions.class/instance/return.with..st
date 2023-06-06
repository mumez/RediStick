instance creation
return: aCount with: identifiers
	self options
		addAll: {
				'RETURN'.
				aCount asString };
		addAll: identifiers.