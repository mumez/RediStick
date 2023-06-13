private
isEnabled: key in: consumingHints
	^ ((consumingHints includesKey: key) and: [consumingHints at: key])