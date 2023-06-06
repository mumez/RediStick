instance creation
sortBy: sortBy ascDesc: ascDesc
	self options addAll: {
				'SORTBY'.
				sortBy asString.
				ascDesc asString }.