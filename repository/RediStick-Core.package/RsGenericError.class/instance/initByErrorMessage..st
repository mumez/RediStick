initialize-release
initByErrorMessage: aSingleLineOfErrorMessage
	self otherInfo at: 'message' put: aSingleLineOfErrorMessage.
	self messageText: aSingleLineOfErrorMessage.
	errorPrefix := aSingleLineOfErrorMessage asString readStream upTo: Character space.
