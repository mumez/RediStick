startup - shutdown
subscribeAllOnStartUp
	[ 2 seconds wait.
	[ self subscribeAll; start ]
		on: SkError
		do: [ :ex | ex inspect ] ] fork