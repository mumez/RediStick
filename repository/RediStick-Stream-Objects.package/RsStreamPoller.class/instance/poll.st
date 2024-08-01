actions
poll
	| received |
	received := self basicPoll.
	received do: [ :each |
		| processed |
		processed := true.
		[ self onReceive value: each ]
			on: Error
			do: [ :ex |
				processed := false.
				self onReceiveFail value: ex value: each ].
		processed ifTrue: [ self currentId: each id ] ]