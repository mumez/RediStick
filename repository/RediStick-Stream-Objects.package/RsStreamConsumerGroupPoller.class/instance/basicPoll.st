private
basicPoll
	| entries |
	entries := OrderedCollection new.
	self shouldAutoClaim ifTrue: [ 
		self claimPending
	].
	entries addAll: self pollPending.
	entries addAll: self pollNeverDelivered.
	^ entries