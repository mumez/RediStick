*RediStick-Search
ftCreate: indexName schema: schema options: options 
	| args |
	args := OrderedCollection new.
	options ifNotNil: [options createArgumentsOn: args].
	schema createArgumentsOn: args.
	^ self ftCommand: 'CREATE' withAll: {indexName},  args 