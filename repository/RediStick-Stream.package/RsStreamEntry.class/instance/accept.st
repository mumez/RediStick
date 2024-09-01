actions
accept
	^ self acceptor ifNotNil: [:acc | acc value: self]