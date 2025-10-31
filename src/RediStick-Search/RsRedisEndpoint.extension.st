Extension { #name : 'RsRedisEndpoint' }

{ #category : '*RediStick-Search' }
RsRedisEndpoint >> dictionaryFrom: pairs except: keys [
	| dict |
	dict := Dictionary newFromPairs: pairs.
	dict keysAndValuesDo: [ :k :v |
		((v isMemberOf: OrderedCollection) and: [ (keys includes: k) not ])
			ifTrue: [ dict at: k put: (self dictionaryFrom: v except: #()) ] ].
	^ dict
]

{ #category : '*RediStick-Search' }
RsRedisEndpoint >> ftAddAlias: alias of: indexName [
	^ self ftCommand: 'ALIASADD' withAll: {alias. indexName} 
]

{ #category : '*RediStick-Search' }
RsRedisEndpoint >> ftAggregateProfile: indexName isLimited: isLimited query: query [
	^ self
		  ftProfile: indexName
		  type: 'AGGREGATE'
		  isLimited: isLimited
		  query: query
]

{ #category : '*RediStick-Search' }
RsRedisEndpoint >> ftCommand: commandName withAll: arguments [

	^ self unifiedCommand: { ('FT.' , commandName) } , arguments
]

{ #category : '*RediStick-Search' }
RsRedisEndpoint >> ftCreate: indexName schema: schema options: options [ 
	| args |
	args := OrderedCollection new.
	options ifNotNil: [options createArgumentsOn: args].
	schema createArgumentsOn: args.
	^ self ftCommand: 'CREATE' withAll: {indexName},  args 
]

{ #category : '*RediStick-Search' }
RsRedisEndpoint >> ftCreate: indexName schemaUsing: schemaBuilder [
	^self ftCreate: indexName schemaUsing: schemaBuilder optionsUsing: nil
]

{ #category : '*RediStick-Search' }
RsRedisEndpoint >> ftCreate: indexName schemaUsing: schemaBuilder optionsUsing: optionsBuilder [
	| schema options |
	schema := RsSearchIndexSchema in: schemaBuilder.
	options := nil.
	optionsBuilder ifNotNil: [
		options := RsSearchCreateIndexOptions in: optionsBuilder ].
	^ self ftCreate: indexName schema: schema options: options
]

{ #category : '*RediStick-Search' }
RsRedisEndpoint >> ftDropIndex: indexName [
	^ self ftCommand: 'DROPINDEX' withAll: {indexName} 
]

{ #category : '*RediStick-Search' }
RsRedisEndpoint >> ftDropIndexWithDocuments: indexName [
	^ self ftCommand: 'DROPINDEX' withAll: {indexName. 'DD'} 
]

{ #category : '*RediStick-Search' }
RsRedisEndpoint >> ftExplain: indexName query: query dialect: dialect [
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
RsRedisEndpoint >> ftExplainCli: indexName query: query dialect: dialect [
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
RsRedisEndpoint >> ftGetConfig: optionName [
	^ self ftCommand: 'CONFIG' withAll: {'GET'. optionName} 
]

{ #category : '*RediStick-Search' }
RsRedisEndpoint >> ftInfo: indexName [
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
RsRedisEndpoint >> ftListIndexes [
	^ self ftCommand: '_LIST' withAll: {} 
]

{ #category : '*RediStick-Search' }
RsRedisEndpoint >> ftProfile: indexName type: type isLimited: isLimited query: query [
	| args |
	args := {indexName. type }.
	isLimited ifTrue: [ args add: 'LIMITED' ].
	args addAll: {'QUERY'. query }.
	^ self ftCommand: 'PROFILE' withAll: args
]

{ #category : '*RediStick-Search' }
RsRedisEndpoint >> ftRemoveAlias: alias [
	^ self ftCommand: 'ALIASDEL' withAll: {alias} 
]

{ #category : '*RediStick-Search' }
RsRedisEndpoint >> ftSearch: indexName query: query [
	^self ftSearch: indexName query: query options: nil
]

{ #category : '*RediStick-Search' }
RsRedisEndpoint >> ftSearch: indexName query: query options: options [ 
	| args results |
	args := OrderedCollection new.
	options ifNotNil: [options createArgumentsOn: args].
	results := self ftCommand: 'SEARCH' withAll: {indexName. query}, args.
	^ RsSearchResultSet fromRawResults: results options: options
]

{ #category : '*RediStick-Search' }
RsRedisEndpoint >> ftSearch: indexName query: query optionsUsing: optionsBuilder [
	| options |
	options := nil.
	optionsBuilder ifNotNil: [
		options := RsSearchOptions in: optionsBuilder ].
	^ self ftSearch: indexName query: query options: options
]

{ #category : '*RediStick-Search' }
RsRedisEndpoint >> ftSearchProfile: indexName isLimited: isLimited query: query [
	^ self
		  ftProfile: indexName
		  type: 'SEARCH'
		  isLimited: isLimited
		  query: query
]

{ #category : '*RediStick-Search' }
RsRedisEndpoint >> ftSetConfig: optionName to: value [
	^ self ftCommand: 'CONFIG' withAll: {'SET'. optionName. value} 
]

{ #category : '*RediStick-Search' }
RsRedisEndpoint >> ftTagValues: fieldName in: indexName [
	^ self ftCommand: 'TAGVALS' withAll: {indexName. fieldName} 
]

{ #category : '*RediStick-Search' }
RsRedisEndpoint >> ftUpdateAlias: alias of: indexName [
	^ self ftCommand: 'ALIASUPDATE' withAll: {alias. indexName} 
]
