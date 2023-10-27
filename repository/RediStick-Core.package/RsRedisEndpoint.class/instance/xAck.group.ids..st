commands-stream
xAck: key group: group ids: ids
	| args |
	args := {
		        'XACK'.
		        key.
		        group.
		        'STREAM' } asOrderedCollection.
	args addAll: ids.
	^ self unifiedCommand: args