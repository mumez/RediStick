accessing-pending-list
pendingListFrom: startId end: endId limit: count
	^ self endpoint xPending: self streamName group: self name start: startId end: endId count: count