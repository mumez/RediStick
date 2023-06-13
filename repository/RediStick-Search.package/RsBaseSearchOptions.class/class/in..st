evaluating
in: aBlock
	| inst |
	inst := self new.
	aBlock value: inst.
	^ inst