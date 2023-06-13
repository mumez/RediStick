actions
returnFields: searchIndexFields
	| args |
	args := OrderedCollection new.
	searchIndexFields do: [ :each | each createArgumentsOn: args ].
	self options
		addAll: {
				'RETURN'.
				searchIndexFields size asString };
		addAll: args.