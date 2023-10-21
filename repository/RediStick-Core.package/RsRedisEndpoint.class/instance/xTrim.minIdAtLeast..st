commands-stream
xTrim: key minIdAtLeast: minId
	^ self xTrim: key using: [ :opts | opts minIdAtLeast: minId ]