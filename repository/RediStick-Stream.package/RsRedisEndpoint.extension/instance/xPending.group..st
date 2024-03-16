*RediStick-Stream
xPending: key group: group
	| ord |
	ord := self unifiedCommand: {
			       'XPENDING'.
			       key.
			       group }.
	^ RsPendingMessagesSummary fromOrderedCollection: ord