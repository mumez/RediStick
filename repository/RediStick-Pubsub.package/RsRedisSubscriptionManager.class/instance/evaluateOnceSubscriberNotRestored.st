private
evaluateOnceSubscriberNotRestored

	self onSubscriberNotRestored ifNil: [ ^ self ].
	self onSubscriberNotRestored value.
	self onSubscriberNotRestored: nil