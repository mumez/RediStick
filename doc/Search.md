# Working with RediSearch in RediStick

[RediStick](https://github.com/mumez/RediStick) supports [RediSearch](https://redis.io/docs/stack/search/) - a full-text search extension for Redis.

## Installation

### Setting up RediSearch

RediSearch is a component of the [Redis Stack](https://redis.io/docs/stack/) and it is not included in Redis by default.
The easiest way to start a RediSearch enabled Redis is to use the [official docker image](https://hub.docker.com/r/redis/redis-stack).

```bash
docker run -d --name redis-stack -p 6379:6379 -p 8001:8001 -v /local-data/:/data redis/redis-stack:latest
```

### Installing RediStick Search packages

Now you can install RediStick Search packages into Pharo (or GemStone/S).

```smalltalk
Metacello new
  baseline: 'RediStick';
  repository: 'github://mumez/RediStick/repository';
  load: #('Search').
```

If you need tests:

```smalltalk
Metacello new
  baseline: 'RediStick';
  repository: 'github://mumez/RediStick/repository';
  load: #('Search' 'SearchTests').
```

## Usage

### Creating an index

```Smalltalk
stick := RsRediStick targetUrl: 'stack://localhost'.
stick connect.

indexName := 'smalltalk-index'.

endpoint := stick endpoint.

"Define index with schema"
endpoint ftCreate: indexName schemaUsing: [:sc |
	sc numericFieldNamed: 'id'.
	sc textFieldNamed: 'name'.
	sc tagFieldNamed: 'tags'.
] optionsUsing: [:opts | opts prefixes: #('st') ].
```

```Smalltalk
"List index names -> an OrderedCollection('smalltalk-index')"
endpoint ftListIndexes.
```

### Populating data

```Smalltalk
endpoint hSet:'st:1' dictionary: ({'id'-> 1. 'name'->'Pharo Smalltalk'. 'tags'->'OSS,Seaside,PharoJS'} as: Dictionary).
endpoint hSet:'st:2' dictionary: ({'id'-> 2. 'name'->'Squeak Smalltalk'. 'tags'->'OSS,Seaside,Etoys'} as: Dictionary).
endpoint hSet:'st:3' dictionary: ({'id'-> 3. 'name'->'VisualWorks Smalltalk'. 'tags'->'Commercial,Seaside,AppeX'} as: Dictionary).
endpoint hSet:'st:4' dictionary: ({'id'-> 4. 'name'->'GemStone Smalltalk'. 'tags'->'Commercial,Seaside,ODB'} as: Dictionary).
```

### Searching by query

#### Basic usage

```Smalltalk
"Search documents that contain 'Smalltalk'"
resultSet := endpoint ftSearch: indexName query: 'Smalltalk'. "total 4"

"Search documents that contain 'Smalltalk', with scores"
resultSet := endpoint ftSearch: indexName query: 'Smalltalk' optionsUsing: [:opts | opts withScores]. "total 4, all scores are 1"

"You can get document content as a dictionary"
resultSet := endpoint ftSearch: indexName query: 'Pharo'.
resultSet total. "1"
content := (resultSet results at: 1) content.
content at: 'id'. "'1'"
content at: 'name'. "'Pharo Smalltalk'"

```

#### Query variations

```Smalltalk
"Prefix query"
resultSet := endpoint ftSearch: indexName query: 'Visual*'. "total 1"

"Exact match query"
resultSet := endpoint ftSearch: indexName query: '"VisualWorks Smalltalk"'. "total 1"

"Specifying numeric field"
resultSet := ep ftSearch: indexName query: '@id:[1 3]' optionsUsing: [:opts | opts noContent ]. "documents with id 1-3"
resultSet documentIds asArray sorted. "#('st:1' 'st:2' 'st:3')"

"Specifying tag field"
resultSet := endpoint ftSearch: indexName query: '@tags:{ OSS }'. "documents with OSS tag. total 2"
resultSet := endpoint ftSearch: indexName query: '@tags:{ OSS | Commercial }'. "documents with 'OSS' or 'Commercial' tag. total 4"
resultSet := endpoint ftSearch: indexName query: '@tags:{ OSS } @tags:{ PharoJS }'. "documents with 'OSS' and 'PharoJS' tag. total 1"

```

#### Query with limit and offset

```Smalltalk
resultSet := endpoint ftSearch: indexName query: 'Smalltalk*' optionsUsing: [:opts | opts offset: 1 limit: 2].
resultSet results collect: [:each | each content]. "an OrderedCollection(a Dictionary('id'->'2' 'name'->'Squeak Smalltalk'
'tags'->'OSS,Seaside,Etoys' ) a Dictionary('id'->'3' 'name'->'VisualWorks
Smalltalk' 'tags'->'Commercial,Seaside,AppeX' ))"
```

For more query patterns, you can see the [query syntax](https://redis.io/docs/stack/search/reference/query_syntax/) reference.

### Dropping an index

```Smalltalk
"Drop index only"
endpoint ftDropIndex: indexName.

"Drop index and documents"
endpoint ftDropIndexWithDocuments: indexName.

"List index names -> an OrderedCollection()"
endpoint ftListIndexes.
```

## ToDo

- [] [Aggregations](https://redis.io/docs/stack/search/reference/aggregations/) Support
