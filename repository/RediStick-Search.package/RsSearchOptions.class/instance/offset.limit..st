actions
offset: offset limit: num
	self options addAll: {
				'LIMIT'.
				offset asString.
				num asString }.