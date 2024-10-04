private
entriesFrom: entryId count: step
	self isInclusive ifTrue: [ ^ self contentsFrom: entryId count: step ].
	^ self contentsNextFrom: entryId count: step