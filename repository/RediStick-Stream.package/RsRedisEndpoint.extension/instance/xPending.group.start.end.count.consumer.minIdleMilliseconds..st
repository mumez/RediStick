*RediStick-Stream
xPending: key group: group start: startId end: endId count: count consumer: consumer minIdleMilliseconds: milliseconds
	| opts ord |
	opts := RsStreamPendingMessagesOptions new.
	opts start: startId; end: endId; count: count.
	consumer ifNotNil: [:con | opts consumer: con ].
	milliseconds ifNotNil: [:msecs | opts minIdleMilliseconds: msecs ].
	ord := self unifiedCommand: {
			       'XPENDING'.
			       key.
			       group }, opts asArray.
	^ ord collect: [:each | RsPendingMessage fromOrderedCollection: each]