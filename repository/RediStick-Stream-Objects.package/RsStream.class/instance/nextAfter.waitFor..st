reading
nextAfter: latestMessageId waitFor: milliseconds
	^ self nextAtMost: 1 after: latestMessageId waitFor: milliseconds