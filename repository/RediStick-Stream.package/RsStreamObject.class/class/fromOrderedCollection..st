instance creation
fromOrderedCollection: values
	| inst |
	inst := self new.
	inst initFromOrderedCollection: values.
	^ inst