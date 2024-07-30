actions
poll
	| received |
	received := self basicPoll.
	received do: [ :each |
		| processed |
		processed := true.
		[ self onReceived value: each ]
			on: Error
			do: [ :ex |
				processed := false.
				self onReceiveNotAccepted value: ex value: each ].
		processed ifTrue: [ self currentId: each id ] ]