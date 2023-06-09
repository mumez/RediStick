*RediStick-Search
ftProfile: indexName type: type isLimited: isLimited query: query
	| args |
	args := {indexName. type }.
	isLimited ifTrue: [ args add: 'LIMITED' ].
	args addAll: {'QUERY'. query }.
	^ self ftCommand: 'PROFILE' withAll: args