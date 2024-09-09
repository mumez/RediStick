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

### Iterating Over Stream Data

You can also use an iterator to process each element in a block.

```Smalltalk
reader3 := RsStream new.
reader3 name: 'chat-room-0001'.

Transcript clear.

"Forward iterator"
"Get an iterator which begins from the second element"
iterator := reader3 iteratorNextFrom: reader3 first id.
iterator do: [:each |
	Transcript crShow: each.
].

Transcript crShow: '----'.

"Reverse iterator"
iterator reversed do: [:each |
	Transcript crShow: each.
]
```

<details>
<summary>
Transcript
</summary>

```Smalltalk
1725711950458-0:{'message'->'Hello'. 'user'->'john'}
1725711950459-0:{'message'->'Hi'. 'user'->'lily'}
1725711950460-0:{'message'->'Nice to meet you'. 'user'->'john'}
1725712771881-0:{'message'->'Nice to meet you, too'. 'user'->'lily'}
1725715484466-0:{'time'->'10:24:44.465 pm'}
----
1725712771881-0:{'message'->'Nice to meet you, too'. 'user'->'lily'}
1725711950460-0:{'message'->'Nice to meet you'. 'user'->'john'}
1725711950459-0:{'message'->'Hi'. 'user'->'lily'}
1725711950458-0:{'message'->'Hello'. 'user'->'john'}
1725711950457-0:{'message'->'Root 0001 created'. 'user'->'system'}
```

</details>

### Polling Incoming Data

It is also possible to process incoming stream data asynchronously using Poller.

```Smalltalk
poller1 := strm pollerIncoming.
poller1 onReceive: [ :each | Transcript crShow: ('poller1: ', each asString) ].
poller1 start.

poller2 := strm pollerIncoming.
poller2 onReceive: [ :each | Transcript crShow: ('poller1: ', each asString)  ].
poller2 start.
```

In this example, poller1 and poller2 can receive incoming data in their own threads.

Let's add new entries to the stream.

```Smalltalk
1 to: 10 do: [ :idx |
	strm nextPut: idx -> Time now printString.
]
```

<details>
<summary>
Transcript
</summary>

```Smalltalk
poller2: 1725889267322-0:{'1'->'10:41:07.321 pm'}
poller1: 1725889267322-0:{'1'->'10:41:07.321 pm'}
poller2: 1725889267323-0:{'2'->'10:41:07.323 pm'}
poller2: 1725889267324-0:{'3'->'10:41:07.324 pm'}
poller1: 1725889267323-0:{'2'->'10:41:07.323 pm'}
poller2: 1725889267325-0:{'4'->'10:41:07.325 pm'}
poller1: 1725889267324-0:{'3'->'10:41:07.324 pm'}
poller1: 1725889267325-0:{'4'->'10:41:07.325 pm'}
poller2: 1725889267325-1:{'5'->'10:41:07.325 pm'}
poller2: 1725889267326-0:{'6'->'10:41:07.326 pm'}
poller1: 1725889267325-1:{'5'->'10:41:07.325 pm'}
poller1: 1725889267326-0:{'6'->'10:41:07.326 pm'}
poller2: 1725889267327-0:{'7'->'10:41:07.327 pm'}
poller1: 1725889267327-0:{'7'->'10:41:07.327 pm'}
poller2: 1725889267328-0:{'8'->'10:41:07.327 pm'}
poller1: 1725889267328-0:{'8'->'10:41:07.327 pm'}
poller1: 1725889267329-0:{'9'->'10:41:07.329 pm'}
poller2: 1725889267329-0:{'9'->'10:41:07.329 pm'}
poller2: 1725889267331-0:{'10'->'10:41:07.33 pm'}
poller1: 1725889267331-0:{'10'->'10:41:07.33 pm'}
```

</details>

By using Poller, you can easily fan out event data to multiple clients.
