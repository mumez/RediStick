generating
createArgumentsOn: args
	args add: self name.
	self alias ifNotEmpty:[args add: ('AS ', self alias)].
	self type ifNotEmpty:[args add: self type].
	args addAll: self options.
	^ args