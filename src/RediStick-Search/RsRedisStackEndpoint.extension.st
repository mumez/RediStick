Extension { #name : 'RsRedisStackEndpoint' }

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> dictionaryFrom: pairs except: keys [
	| dict |
	dict := Dictionary newFromPairs: pairs.
	dict keysAndValuesDo: [ :k :v |
		((v isMemberOf: OrderedCollection) and: [ (keys includes: k) not ])
			ifTrue: [ dict at: k put: (self dictionaryFrom: v except: #()) ] ].
	^ dict
]

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> ftAddAlias: alias of: indexName [
	^ self ftCommand: 'ALIASADD' withAll: {alias. indexName} 
]

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> ftAggregateProfile: indexName isLimited: isLimited query: query [
	^ self
		  ftProfile: indexName
		  type: 'AGGREGATE'
		  isLimited: isLimited
		  query: query
]

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> ftCommand: commandName withAll: arguments [

	^ self unifiedCommand: { ('FT.' , commandName) } , arguments
]

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> ftCreate: indexName schema: schema options: options [ 
	| args |
	args := OrderedCollection new.
	options ifNotNil: [options createArgumentsOn: args].
	schema createArgumentsOn: args.
	^ self ftCommand: 'CREATE' withAll: {indexName},  args 
]

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> ftCreate: indexName schemaUsing: schemaBuilder [
	^self ftCreate: indexName schemaUsing: schemaBuilder optionsUsing: nil
]

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> ftCreate: indexName schemaUsing: schemaBuilder optionsUsing: optionsBuilder [
	| schema options |
	schema := RsSearchIndexSchema in: schemaBuilder.
	options := nil.
	optionsBuilder ifNotNil: [
		options := RsSearchCreateIndexOptions in: optionsBuilder ].
	^ self ftCreate: indexName schema: schema options: options
]

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> ftDropIndex: indexName [
	^ self ftCommand: 'DROP' withAll: {indexName} 
]

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> ftDropIndexWithDocuments: indexName [
	^ self ftCommand: 'DROP' withAll: {indexName. 'DD'} 
]

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> ftExplain: indexName query: query dialect: dialect [
	| args |
	args := OrderedCollection new.
	dialect ifNotNil: [
		args add: {
				'DIALECT'.
				dialect } ].
	^ self ftCommand: 'EXPLAIN' withAll: {
			  indexName.
			  query } , args
]

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> ftExplainCli: indexName query: query dialect: dialect [
	| args |
	args := OrderedCollection new.
	dialect ifNotNil: [
		args add: {
				'DIALECT'.
				dialect } ].
	^ self ftCommand: 'EXPLAINCLI' withAll: {
			  indexName.
			  query } , args
]

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> ftGetConfig: optionName [
	^ self ftCommand: 'CONFIG' withAll: {'GET'. optionName} 
]

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> ftInfo: indexName [
	| infoPairs info rawAttributes |
	infoPairs := self ftCommand: 'INFO' withAll: {indexName}.
	info := self dictionaryFrom: infoPairs except: #('attributes').
	rawAttributes := info at: 'attributes' ifAbsent: [ ^ info ].
	info at: 'attributes' put: (
		rawAttributes collect: [ :each | self dictionaryFrom: each except: #() ]
	).
	^ info
]

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> ftListIndexes [
	^ self ftCommand: '_LIST' withAll: {} 
]

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> ftProfile: indexName type: type isLimited: isLimited query: query [
	| args |
	args := {indexName. type }.
	isLimited ifTrue: [ args add: 'LIMITED' ].
	args addAll: {'QUERY'. query }.
	^ self ftCommand: 'PROFILE' withAll: args
]

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> ftRemoveAlias: alias [
	^ self ftCommand: 'ALIASDEL' withAll: {alias} 
]

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> ftSearch: indexName query: query [
	^self ftSearch: indexName query: query options: nil
]

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> ftSearch: indexName query: query options: options [ 
	| args results |
	args := OrderedCollection new.
	options ifNotNil: [options createArgumentsOn: args].
	results := self ftCommand: 'SEARCH' withAll: {indexName. query}, args.
	^ RsSearchResultSet fromRawResults: results options: options
]

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> ftSearch: indexName query: query optionsUsing: optionsBuilder [
	| options |
	options := nil.
	optionsBuilder ifNotNil: [
		options := RsSearchOptions in: optionsBuilder ].
	^ self ftSearch: indexName query: query options: options
]

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> ftSearchProfile: indexName isLimited: isLimited query: query [
	^ self
		  ftProfile: indexName
		  type: 'SEARCH'
		  isLimited: isLimited
		  query: query
]

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> ftSetConfig: optionName to: value [
	^ self ftCommand: 'CONFIG' withAll: {'SET'. optionName. value} 
]

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> ftTagValues: fieldName in: indexName [
	^ self ftCommand: 'TAGVALS' withAll: {indexName. fieldName} 
]

{ #category : '*RediStick-Search' }
RsRedisStackEndpoint >> ftUpdateAlias: alias of: indexName [
	^ self ftCommand: 'ALIASUPDATE' withAll: {alias. indexName} 
]
