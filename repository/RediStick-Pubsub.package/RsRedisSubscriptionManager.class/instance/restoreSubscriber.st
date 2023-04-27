factory
restoreSubscriber
	self releaseSubscriber.
	[
	(Delay forSeconds: self restoreSubscriberWaitSeconds) wait.
	[ self subscriber pingOk ]
		on: Error
		do: [:ex |
			self releaseSubscriber.
			false ] ] whileFalse.
	Transcript crShow: '-subscribe again-'.
	self subscribeChannels