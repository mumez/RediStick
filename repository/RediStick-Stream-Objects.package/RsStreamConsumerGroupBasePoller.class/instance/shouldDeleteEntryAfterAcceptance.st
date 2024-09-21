accessing
shouldDeleteEntryAfterAcceptance
	^ shouldDeleteEntryAfterAcceptance ifNil: [ shouldDeleteEntryAfterAcceptance := false ]