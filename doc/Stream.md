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

## Advanced Usage

### Using Consumer Groups

Consumer groups allow multiple stream consumers to cooperate and process data from the same stream. Each stream entry is delivered to only one consumer in the group, ensuring that the workload is distributed.

#### Creating a Consumer Group and Consumers

Let's create a consumer group named 'group1' and register four consumers named 'C1' to 'C4'.

```smalltalk
strm := RsStream new.
strm name: 'time-events-001'.
consumerGroup := strm consumerGroupNamed: 'group1'.
consumer1 := consumerGroup consumerNamed: 'C1'.
consumer2 := consumerGroup consumerNamed: 'C2'.
consumer3 := consumerGroup consumerNamed: 'C3'.
consumer4 := consumerGroup consumerNamed: 'C4'.
consumersInfo := consumerGroup consumersInfo.
```

<details>
<summary>
consumersInfo
</summary>

```smalltalk
an OrderedCollection(name: 'C1'
pending: 0
idle: 321797
inactive: -1 name: 'C2'
pending: 0
idle: 321796
inactive: -1 name: 'C3'
pending: 0
idle: 321794
inactive: -1 name: 'C4'
pending: 0
idle: 321793
inactive: -1)
```

</details>

#### Processing Sharded Stream Entries

Typically, a consumer waits for incoming data using a loop. Therefore, we should define a polling process for that purpose.

```Smalltalk
poller := [:consumer |
    5 timesRepeat: [ | entries |
        "Pick two incoming entries"
        entries := consumer neverDeliveredAtMost: 2.
        entries do: [ :each |
            "Show each entry with the consumer's name"
            Transcript crShow: (consumer name, '>', each asString)
        ]
    ]
].
```

Each consumer can process at most 10 entries in this case. After adding 20 entries to the stream, we apply the looping process to each consumer and observe the results.

```Smalltalk
"Putting data"
1 to: 20 do: [ :idx |
    strm nextPut: idx -> Time now printString.
].

"Make all consumers start polling"
{consumer1. consumer2. consumer3. consumer4} do: [:each | [poller value: each] fork ].
```

<details>
<summary>
Transcript
</summary>

```Smalltalk
C1>1726236992833-0:{'1'->'11:16:32.833 pm'}
C1>1726236992834-0:{'2'->'11:16:32.834 pm'}
C2>1726236992834-1:{'3'->'11:16:32.834 pm'}
C2>1726236992835-0:{'4'->'11:16:32.835 pm'}
C3>1726236992835-1:{'5'->'11:16:32.835 pm'}
C3>1726236992836-0:{'6'->'11:16:32.836 pm'}
C4>1726236992836-1:{'7'->'11:16:32.836 pm'}
C4>1726236992837-0:{'8'->'11:16:32.837 pm'}
C1>1726236992838-0:{'9'->'11:16:32.838 pm'}
C1>1726236992838-1:{'10'->'11:16:32.838 pm'}
C2>1726236992839-0:{'11'->'11:16:32.839 pm'}
C2>1726236992839-1:{'12'->'11:16:32.839 pm'}
C3>1726236992840-0:{'13'->'11:16:32.84 pm'}
C3>1726236992841-0:{'14'->'11:16:32.84 pm'}
C4>1726236992841-1:{'15'->'11:16:32.841 pm'}
C4>1726236992842-0:{'16'->'11:16:32.842 pm'}
C1>1726236992842-1:{'17'->'11:16:32.842 pm'}
C1>1726236992843-0:{'18'->'11:16:32.843 pm'}
C2>1726236992843-1:{'19'->'11:16:32.843 pm'}
C2>1726236992844-0:{'20'->'11:16:32.844 pm'}

```

</details>

Now you can see that consumers process some part of all entries. The same entry is never delivered to multiple consumers.

#### Accept Pending Entries

In fact, in the previous example, the consumers never finish processing the data. Each consumer has its own list of pending entries.

```Smalltalk
pendings := consumer1 allPendings.
```

<details>
<summary>
pendings
</summary>

```Smalltalk
an OrderedCollection(1726236992833-0:{'1'->'11:16:32.833 pm'}
1726236992834-0:{'2'->'11:16:32.834 pm'} 1726236992838-0:{'9'->'11:16:32.838
pm'} 1726236992838-1:{'10'->'11:16:32.838 pm'}
1726236992842-1:{'17'->'11:16:32.842 pm'} 1726236992843-0:{'18'->'11:16:32.843
pm'})
```

</details>

This happens because you did not send an #accept message for the entries you received. The following code clears the pending entries list:

```Smalltalk
"Mark that entries are correctly processed"
pendings do: [:each | each accept].
```

Pending entries are messages that have been delivered to the consumer but have not yet been acknowledged. The pending list is provided for retry purposes. By explicitly accepting an entry, you ensure that it is processed only once by one client.

Typically, you should write a loop that sends #accept if there are no errors in data processing.

```Smalltalk
poller := [:consumer |
    5 timesRepeat: [ | entries |
        "Pick two incoming entries"
        entries := consumer neverDeliveredAtMost: 2.
        entries do: [ :each |
            "Show each entry with the consumer's name"
            Transcript crShow: (consumer name, '>', each asString).
            each accept. "Acknowledge the reception"
        ]
    ]
].

```
