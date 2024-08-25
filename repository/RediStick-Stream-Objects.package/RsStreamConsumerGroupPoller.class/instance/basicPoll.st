private
basicPoll
	| entries |
	entries := OrderedCollection new.
	self shouldAutoClaim ifTrue: [ 
		entries addAll: self claimPending.
	].
	entries addAll: self pollPending.
	entries addAll: self pollNeverDelivered.
	^ entries