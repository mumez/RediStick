private
ensureAssociations: keyValuesOrAssociation

	^ keyValuesOrAssociation isCollection
		  ifTrue: [ keyValuesOrAssociation ]
		  ifFalse: [ { keyValuesOrAssociation } ]