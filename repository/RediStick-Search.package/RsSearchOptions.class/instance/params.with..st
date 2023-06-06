instance creation
params: nargs with: nameValues
	self options
		addAll: {
				'PARAMS'.
				nargs asString };
		addAll: nameValues