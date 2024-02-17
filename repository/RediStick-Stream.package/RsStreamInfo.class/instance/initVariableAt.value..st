initialization
initVariableAt: key value: value
	key = 'length' ifTrue: [ ^ self length: value ].
	key = 'radix-tree-keys' ifTrue: [ ^ self radixTreeKeys: value ].
	key = 'radix-tree-nodes' ifTrue: [ ^ self radixTreeNodes: value ].
	key = 'last-generated-id' ifTrue: [ ^ self lastGeneratedId: value ].
	key = 'max-deleted-entry-id' ifTrue: [
		^ self maxDeletedEntryId: value ].
	key = 'entries-added' ifTrue: [ ^ self entriesAdded: value ].
	key = 'groups' ifTrue: [ ^ self initGroup: value].
	key = 'first-entry' ifTrue: [ ^ self firstEntry: (RsStreamEntry fromOrderedCollection: value) ].
	key = 'last-entry' ifTrue: [ ^ self lastEntry: (RsStreamEntry fromOrderedCollection: value) ].
	key = 'entries' ifTrue: [ ^ self initEntries: value ].