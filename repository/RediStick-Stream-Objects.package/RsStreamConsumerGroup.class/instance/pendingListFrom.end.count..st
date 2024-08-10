accessing-pending-list
pendingListFrom: startId end: endId count: count
	^ self endpoint xPending: self streamName group: self name start: startId end: endId count: count