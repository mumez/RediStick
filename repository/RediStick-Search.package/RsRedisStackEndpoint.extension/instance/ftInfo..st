*RediStick-Search
ftInfo: indexName
	| infoPairs info rawAttributes |
	infoPairs := self ftCommand: 'INFO' withAll: {indexName}.
	info := self dictionaryFrom: infoPairs except: #('attributes').
	rawAttributes := info at: 'attributes' ifAbsent: [ ^ info ].
	info at: 'attributes' put: (
		rawAttributes collect: [ :each | self dictionaryFrom: each except: #() ]
	).
	^ info