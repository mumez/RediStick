initialization
initPending: value
	| pnds |
	pnds := value isInteger
		        ifTrue: [ value ]
		        ifFalse: [
			        value collect: [ :each |
				        RsStreamPendingEntry fromOrderedCollection: each ] ].
	self pending: pnds