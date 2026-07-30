# Working with Time Series in RediStick

[RediStick](https://github.com/mumez/RediStick) supports [Redis TimeSeries](https://redis.io/docs/latest/develop/data-types/timeseries/) - a time series data type for Redis.

Redis TimeSeries is included in Redis 8.0 and later. For earlier versions, you can use Redis with the TimeSeries module support.

## Installation

### Installing RediStick TimeSeries packages

You can install RediStick TimeSeries packages into Pharo (or GemStone/S).

```smalltalk
Metacello new
  baseline: 'RediStick';
  repository: 'github://mumez/RediStick/src';
  load: #('TimeSeries').
```

If you need tests:

```smalltalk
Metacello new
  baseline: 'RediStick';
  repository: 'github://mumez/RediStick/src';
  load: #('TimeSeries' 'TimeSeriesTests').
```

## Basic Usage

### Setting up Connection

```smalltalk
stick := RsRediStick targetUrl: 'sync://localhost'.
stick connect.
```

### Creating a Time Series

```smalltalk
"Create a time series with default options"
stick endpoint tsCreate: 'temperature:1'.

"Create with options"
stick endpoint tsCreate: 'temperature:2' using: [:opts |
    opts retention: 86400000; "keep 1 day of samples (ms)"
        labels: {'sensor_id'->'2'. 'area'->'kitchen'} asDictionary].
```

### Adding Samples

```smalltalk
"Add a sample with an explicit timestamp (DateAndTime or milliseconds)"
stick endpoint tsAdd: 'temperature:1' timestamp: (ts := DateAndTime now) value: 25.5.

"Add a later sample with an explicit timestamp, so it becomes the previous one"
stick endpoint tsAdd: 'temperature:1' timestamp: ts - 10 minutes value: 26.1.

"Add a sample, letting Redis auto-assign the timestamp ('*')"
stick endpoint tsAdd: 'temperature:2' value: 21.0.

"Add with options - e.g. set retention and labels on auto-create (the series is
auto-created by TS.ADD even without options)"
stick endpoint tsAdd: 'temperature:3' value: 22.0 using: [:opts |
    opts retention: 3600000; labels: {'sensor_id'->'3'} asDictionary].
```

### Getting the Last Sample

```smalltalk
"Returns a timestamp -> value Association, or nil if the series is empty"
sample := stick endpoint tsGet: 'temperature:1'.
sample key.    "the timestamp in milliseconds (ts asRediStickUnixTimestampMillis)"
sample value.  "25.5, the most recently added sample"
```

### Incrementing / Decrementing Values

```smalltalk
stick endpoint tsIncrBy: 'temperature:1' increment: 0.5.
stick endpoint tsDecrBy: 'temperature:1' decrement: 0.2.

"With an explicit timestamp and options"
stick endpoint tsIncrBy: 'temperature:1' timestamp: DateAndTime now increment: 1
    using: [:opts | opts retention: 86400000].
```

### Series Info

```smalltalk
info := stick endpoint tsInfo: 'temperature:1'.
info at: 'totalSamples'.   "5"
info at: 'retentionTime'.  "0"
```

### Altering a Series

```smalltalk
stick endpoint tsAlter: 'temperature:1' retention: 604800000.
stick endpoint tsAlter: 'temperature:1' labels: {'area'->'living_room'} asDictionary.
stick endpoint tsAlter: 'temperature:1' using: [:opts |
    opts duplicatePolicy: 'LAST'; chunkSize: 4096].
```

## Querying a Range

```smalltalk
"Query the whole series"
values := stick endpoint tsRange: 'temperature:1' rangeBy: [:range | range all].
"{1785221260286->26.1. 1785221860286->25.5. 1785221992582->26.
1785221996713->25.8. 1785222002419->26.8}"

"Query a specific range - '-'/'+' via `all`, or explicit timestamps association"
values := stick endpoint tsRange: 'temperature:1'
    rangeBy: [:range | ts -> range end].

"Each element is a timestamp -> value Association"
values do: [:sample | Transcript cr; show: sample key asString, ': ', sample value asString].

"Reverse order"
values := stick endpoint tsRevRange: 'temperature:1' rangeBy: [:range | range all].
```

### Range with Aggregation

```smalltalk
"Average over 1-minute (60000ms) buckets"
values := stick endpoint tsRange: 'temperature:1'
    rangeBy: [:range | range all]
    aggregationBy: [:agg :aggOpts | agg avg; bucketDuration: 60000].

"Additional aggregation options: ALIGN, BUCKETTIMESTAMP, EMPTY"
values := stick endpoint tsRange: 'temperature:1'
    rangeBy: [:range | range all]
    aggregationBy: [:agg :aggOpts |
        agg avg; bucketDuration: 60000.
        aggOpts bucketTimestampEnd; empty].
```

## Batch Adding Samples

```smalltalk
"Using the fluent interface"
stick endpoint tsMAddUsing: [:multiAdd |
    multiAdd
        key: 'temperature:1' timestamp: DateAndTime now value: 25.0;
        key: 'temperature:2' timestamp: DateAndTime now value: 21.5].

"From a Dictionary of key -> value (auto timestamp)"
stick endpoint tsMAddWithDictionary: {'temperature:1'->25.0. 'temperature:2'->21.5} asDictionary.

"From key/value pairs (auto timestamp)"
stick endpoint tsMAddWithKeyValues: {{'temperature:1'. 25.0}. {'temperature:2'. 21.5}}.

"From key/timestamp/value triplets"
stick endpoint tsMAddWithKeyTimestampValues:
    {{'temperature:1'. DateAndTime now. 25.0}. {'temperature:2'. DateAndTime now. 21.5}}.
```

## Multi-Series Queries with Filters

Filters select time series by their labels, using an `RsTsFilter`-based builder passed to `filterBy:`.

```smalltalk
"Get the latest sample from every series with label sensor_id"
values := stick endpoint tsMGetFilterBy: [:filter | filter hasLabel: 'sensor_id'].
values do: [:v |
    Transcript cr; show: v key, ' @', v timestamp asString, ': ', v value asString].

"With options - WITHLABELS, LATEST, SELECTED_LABELS"
values := stick endpoint tsMGetFilterBy: [:filter | filter label: 'area' eq: 'kitchen']
    using: [:opts | opts withLabels].

"RsTsValue holds key, timestamp, value and labels"
values first labels. "a Dictionary with the series' labels"
```

### MRANGE / MREVRANGE

```smalltalk
"Range query across all matching series"
results := stick endpoint tsMRangeBy: [:range | range all]
    filterBy: [:filter | filter label: 'area' eq: 'kitchen'].

"Each result is an RsTsRangeValue"
results do: [:r |
    Transcript cr; show: r key, ': ', r values size asString, ' samples'].

"With aggregation and options"
results := stick endpoint tsMRangeBy: [:range | range all]
    filterBy: [:filter | filter hasLabel: 'sensor_id']
    aggregationBy: [:agg :aggOpts | agg avg; bucketDuration: 60000]
    using: [:opts | opts withLabels].

"With GROUPBY / REDUCE - returns RsTsGroupedRangeValue"
grouped := stick endpoint tsMRangeBy: [:range | range all]
    filterBy: [:filter | filter hasLabel: 'area']
    aggregationBy: [:agg :aggOpts | agg avg; bucketDuration: 60000]
    groupBy: [:g | g label: 'area'; reduce: 'avg'].
grouped first groupByLabel. "'area'->'kitchen'"
grouped first sourceKeys.   "series keys that contributed to this group"

"Reverse order variant"
results := stick endpoint tsMRevRangeBy: [:range | range all]
    filterBy: [:filter | filter hasLabel: 'sensor_id'].
```

### Querying Series Keys by Label (QUERYINDEX)

```smalltalk
keys := stick endpoint tsQueryIndexFilterBy: [:filter | filter label: 'area' eq: 'kitchen'].
"#('temperature:2' 'temperature:3')"
```

## Compaction Rules

```smalltalk
"Create a destination series for 1-hour averages, then a compaction rule"
stick endpoint tsCreate: 'temperature:1:hourly'.
stick endpoint tsCreateRule: 'temperature:1' dest: 'temperature:1:hourly'
    aggregationBy: [:agg | agg avg; bucketDuration: 3600000].

"Delete the rule"
stick endpoint tsDeleteRule: 'temperature:1' dest: 'temperature:1:hourly'.
```

A destination series with a compaction rule is a *compacted* series: its samples are
derived aggregates written by Redis rather than points added directly. When reading
from a compacted series, the last bucket may still be incomplete (not yet closed),
so `TS.GET`/`TS.MGET` can return a partial, still-changing value by default. Pass
`LATEST` to include that last, possibly incomplete, bucket instead of skipping it:

```smalltalk
"Use the LATEST flag when reading from a compacted series"
sample := stick endpoint tsGet: 'temperature:1:hourly' latest: true.

values := stick endpoint tsMGetFilterBy: [:filter | filter label: 'area' eq: 'kitchen']
    using: [:opts | opts latest].
```

## Deleting Samples and Cleaning Up

```smalltalk
"Delete all samples between two timestamps (inclusive)"
stick endpoint tsDel: 'temperature:1' from: (DateAndTime now - 1 hour) to: DateAndTime now.

"Remove the demo keys entirely"
stick endpoint del: #('temperature:1' 'temperature:2' 'temperature:3' 'temperature:1:hourly').
```

## References

- [Redis TimeSeries Overview](https://redis.io/docs/latest/develop/data-types/timeseries/)
- [Redis TimeSeries Commands](https://redis.io/docs/latest/commands/?group=timeseries)
