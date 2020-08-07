private
errorHandlingDo: aBlock returning: returnBlock
	^ [ aBlock value ]
		on: Error
		do: [ :ex | 
			(ex isKindOf: RsGenericError)
				ifTrue: [ self onRedisGenericErrorSignaled: ex ]
				ifFalse: [ self onErrorSignaled: ex ].
			returnBlock value ]