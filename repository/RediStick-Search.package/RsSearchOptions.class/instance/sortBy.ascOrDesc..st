actions
sortBy: sortBy ascOrDesc: ascOrDesc
	self options addAll: {
				'SORTBY'.
				sortBy asString.
				ascOrDesc asString }.