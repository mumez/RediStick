instance creation
fields: fields

	| inst |
	inst := self new.
	fields do: [ :each | inst addField: each ].
	inst