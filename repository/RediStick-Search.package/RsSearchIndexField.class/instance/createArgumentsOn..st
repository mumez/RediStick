generating
createArgumentsOn: args
	args add: self name.
	self alias ifNotEmpty:[args add: ('AS ', self alias)].
	args addAll: self options.
	^ args