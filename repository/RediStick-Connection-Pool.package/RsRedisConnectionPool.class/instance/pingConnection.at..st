private
pingConnection: aRedis at: key
	| pong |
	pong := [ aRedis ping ]
		on: Error
		do: [ :ex | 
			self logger error: ex.
			nil ].
	(pong isNil or: [ pong ~= 'PONG' ])
		ifTrue: [ self logger info: 'Destroy redis connection'.
			aRedis destroy ]
		ifFalse: [ self returnConnection: aRedis at: key ]