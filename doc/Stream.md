# Data Stream Processing with RediStick

[RediStick](https://github.com/mumez/RediStick) provides high-level streaming data API which is based on [Redis Streams](https://redis.io/docs/latest/develop/data-types/streams/).

## Installation

You can easily install StreamObjects packages into Pharo (or GemStone/S).

```smalltalk
Metacello new
  baseline: 'RediStick';
  repository: 'github://mumez/RediStick/repository';
  load: #('StreamObjects').
```

If you need tests:

```smalltalk
Metacello new
  baseline: 'RediStick';
  repository: 'github://mumez/RediStick/repository';
  load: #('StreamObjects' 'StreamObjectsTests').
```

## Basic Usage

### Writing Stream Data

```Smalltalk
"Prepare a stream named 'chat-room-0001'"
strm := RsStream new.
strm name: 'chat-room-0001'.

"Append data to the stream"
strm << { #message -> 'Root 0001 created'. #user -> 'system' }.
strm << { #message -> 'Hello'. #user -> 'john' }.
strm << { #message -> 'Hi'. #user -> 'lily' }.
strm << { #message -> 'Nice to meet you'. #user -> 'john' }.
strm << { #message -> 'Nice to meet you, too'. #user -> 'lily' }.

"Note: You can also use #nextPut:, #nextPutAssociations:, etc. #<< is just a shortcut"
strm nextPut: #time -> Time now printString.
```

### Reading stream data

#### Read all data in the stream (not recommended for large streams)

```Smalltalk
reader1 := RsStream new.
reader1 name: 'chat-room-0001'.
contents := reader1 contents.
```

<details>
<summary>
contents
</summary>

```Smalltalk
an OrderedCollection(1725711950457-0:{'message'->'Root 0001 created'.
'user'->'system'} 1725711950458-0:{'message'->'Hello'. 'user'->'john'}
1725711950459-0:{'message'->'Hi'. 'user'->'lily'}
1725711950460-0:{'message'->'Nice to meet you'. 'user'->'john'}
1725712771881-0:{'message'->'Nice to meet you, too'. 'user'->'lily'}
1725715484466-0:{'time'->'10:24:44.465 pm'})"
```

</details>

#### Read data in chunks

```Smalltalk
reader2 := RsStream new.
reader2 name: 'chat-room-0001'.

"Read first three entries from the stream"
contents := reader2 first: 3.
messageId := contents last id. "pick the message id for further reading"

"You can read the next chunk of messages after the message ID"
moreContents := reader2 nextAtMost: 10 after: messageId.
```

<details>
<summary>
moreContents
</summary>

```Smalltalk
"an OrderedCollection(1725711950460-0:{'message'->'Nice to meet you'.
'user'->'john'} 1725712771881-0:{'message'->'Nice to meet you, too'.
'user'->'lily'} 1725715484466-0:{'time'->'10:24:44.465 pm'})
```

</details>
