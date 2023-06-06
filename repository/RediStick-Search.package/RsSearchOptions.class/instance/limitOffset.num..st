instance creation
limitOffset: offset num: num
	self options addAll: {
				'LIMIT'.
				offset asString.
				num asString }.