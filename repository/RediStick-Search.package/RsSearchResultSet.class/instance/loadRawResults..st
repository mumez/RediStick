loading
loadRawResults: anArray
	| contentsArray |
	self size: anArray first.
	contentsArray := anArray copyFrom: 2 to: anArray size.
	(contentsArray allSatisfy: [ :each | each isString ]) ifTrue: [ ^ self loadIdsFrom: contentsArray ].
	self loadResultsFrom: contentsArray 