instance creation
timeout: aTimeout
	self options addAll: {
				'TIMEOUT'.
				aTimeout asString }.