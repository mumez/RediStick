private
wrapAsAcceptableEntries: streamEntries
	streamEntries do: [ :each | each acceptor: self defaultAcceptor ].
	^ streamEntries