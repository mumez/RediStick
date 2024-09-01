callback
onPollFail

	^ onPollFail ifNil: [ onPollFail := [:ex | self stop. ex pass] ]