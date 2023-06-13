actions
highlightFields: aCount with: fields tags: tags
	self options
		addAll: {
				'HIGHLIGHT'.
				'FIELDS'.
				aCount asString };
		addAll: fields;
		addAll: {
				'TAGS'.
				tags first asString.
				tags second asString }.