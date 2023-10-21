commands-stream
xTrim: key maxLen: maxLength
	^ self xTrim: key using: [ :opts | opts maxLen: maxLength ]