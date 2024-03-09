initialization
initPending: value
	| pnds |
	pnds := value collect: [ :each |
		        RsStreamPendingEntry fromOrderedCollection: each ].
	self pending: pnds