initialization
initEntries: value
	| ents |
	ents := value collect: [ :each |
		        RsStreamEntry fromOrderedCollection: each ].
	^ self entries: value