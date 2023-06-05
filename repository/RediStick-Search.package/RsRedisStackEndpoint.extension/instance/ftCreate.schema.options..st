*RediStick-Search
ftCreate: indexName schema: schema options: options 
	| args |
	args := OrderedCollection new.
	schema createArgumentsOn: args.
	options createArgumentsOn: args.
	^ self ftCommand: 'CREATE' withAll: {indexName},  args 