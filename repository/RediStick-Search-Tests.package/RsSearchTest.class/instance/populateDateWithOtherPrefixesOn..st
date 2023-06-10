private
populateDateWithOtherPrefixesOn: endpoint
	| otherPrefix |
	self populateDateOn: endpoint.
	otherPrefix := 'rs:test:smalltalk'.
	1 to: 10 do: [ :idx |
		endpoint hSet: (otherPrefix, idx asString) dictionary: 
			({'id'-> idx. 'name'-> ('Smalltalk', idx asString)} as: Dictionary).	
	]