keeping-connection
loopPublishPing

	[ connectionKeeper notNil ] whileTrue: [ 
		[ 
		self publishPing.
		(Delay forSeconds: self intervalSeconds) wait ] ifCurtailed: [ 
			self stopPublishPing ] ]