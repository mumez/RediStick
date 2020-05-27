actions
at: key ifAbsentPut: aBlock
	^ (self at: key) ifNil: [ self at: key put: aBlock value ].