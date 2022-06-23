actions
startUp
	[ 2 seconds wait.
	[ self subscribeChannels; start ]
		on: SkError
		do: [ :ex | ex inspect ] ] fork