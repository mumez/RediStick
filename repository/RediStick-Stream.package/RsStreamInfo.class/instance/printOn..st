printing
printOn: aStream
    aStream nextPutAll: 'length: '.
    self length printOn: aStream.
    aStream cr; nextPutAll: 'radixTreeKeys: '.
    self radixTreeKeys printOn: aStream.
    aStream cr; nextPutAll: 'radixTreeNodes: '.
    self radixTreeNodes printOn: aStream.
    aStream cr; nextPutAll: 'groups: '.
    self groups printOn: aStream.
    aStream cr; nextPutAll: 'lastGeneratedId: '.
    self lastGeneratedId printOn: aStream.
    aStream cr; nextPutAll: 'maxDeletedEntryId: '.
    self maxDeletedEntryId printOn: aStream.
    aStream cr; nextPutAll: 'entriesAdded: '.
    self entriesAdded printOn: aStream.
    aStream cr; nextPutAll: 'firstEntry: '.
    self firstEntry printOn: aStream.
    aStream cr; nextPutAll: 'lastEntry: '.
    self lastEntry printOn: aStream.
    aStream cr; nextPutAll: 'recordedFirstEntryId: '.
    self recordedFirstEntryId printOn: aStream.
    aStream cr; nextPutAll: 'entries: '.
    self entries printOn: aStream.