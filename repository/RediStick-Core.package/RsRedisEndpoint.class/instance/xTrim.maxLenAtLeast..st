commands-stream
xTrim: key maxLenAtLeast: maxLength
	^ self xTrim: key using: [ :opts | opts maxLenAtLeast: maxLength ]