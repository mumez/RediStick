private
basicPoll
	| entries |
	entries := OrderedCollection new.
	entries addAll: self pollPending.
	entries addAll: self pollNeverDelivered.
	^ entries