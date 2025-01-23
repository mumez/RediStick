commands-lists
lPos: aKey value: value rank: rank count: count maxlen: maxlen
	| args |
	args := {
		        'LPOS'.
		        aKey.
		        value } asOrderedCollection.
	rank ifNotNil: [
		args addAll: {
				'RANK'.
				rank } ].
	count ifNotNil: [
		args addAll: {
				'COUNT'.
				count } ].
	maxlen ifNotNil: [
		args addAll: {
				'MAXLEN'.
				maxlen } ].

	^ self unifiedCommand: args