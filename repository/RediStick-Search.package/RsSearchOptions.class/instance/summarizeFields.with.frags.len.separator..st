actions
summarizeFields: aCount with: fields frags: num len: fragsize separator: separator
	self options
		addAll: {
				'SUMMARIZE'.
				'FIELDS'.
				aCount asString };
		addAll: fields;
		addAll: {
				'FRAGS'.
				num asString.
				'LEN'.
				fragsize asString.
				'SEPARATOR'.
				separator asString }.