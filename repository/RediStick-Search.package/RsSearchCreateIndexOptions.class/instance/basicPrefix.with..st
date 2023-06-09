actions
basicPrefix: aCount with: prefixes
	self options
		addAll: {
				'PREFIX'.
				aCount asString };
		addAll: prefixes