instance creation
inKeys: aCount with: keys
    self options
		addAll: {
				'INKEYS'.
				aCount asString };
		addAll: keys.