initialization
initClaimedMessages: rawValues
	self claimedMessages: (rawValues collect: [ :each |
			 each isString
				 ifTrue: [ each ]
				 ifFalse: [ RsStreamEntry fromOrderedCollection: each ] ])