accessing-pending-list
pendingListFrom: startId end: endId atMost: count
	^ self endpoint xPending: self streamName group: self groupName start: startId end: endId count: count consumer: self name