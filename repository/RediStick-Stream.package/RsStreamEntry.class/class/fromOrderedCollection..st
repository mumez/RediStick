instance creation
fromOrderedCollection: keyWithFieldsAndValues
	| inst |
	inst := self new.
	inst initFromOrderedCollection: keyWithFieldsAndValues.
	^ inst