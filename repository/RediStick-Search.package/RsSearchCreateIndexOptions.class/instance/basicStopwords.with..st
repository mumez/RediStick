actions
basicStopwords: aCount with: stopwords
	self options
		addAll: {
				'STOPWORDS'.
				aCount asString };
		addAll: stopwords