callback
onPollFailed

	^ onPollFailed ifNil: [ onPollFailed := [:ex | ex pass] ]