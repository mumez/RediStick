private
basicPoll
	| entries pendings |
	entries := OrderedCollection new.
	[ (pendings := self pollPending) notEmpty ] whileTrue: [
		entries addAll: pendings ].
	entries ifEmpty: [ entries := self pollNeverDelivered ].
	^ entries