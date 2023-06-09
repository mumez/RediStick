instance creation
fromRawResults: anArray
	| inst |
	inst := self new.
	inst loadRawResults: anArray.
	^ inst