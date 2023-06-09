instance creation
fromRawResults: anArray options: options
	| inst |
	inst := self new.
	inst loadRawResults: anArray options: options.
	^ inst