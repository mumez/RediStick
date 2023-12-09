*RediStick-Stream
xClaim: key group: group consumer: consumer minIdleTime: minIdleTime ids: ids using: optionsBlock
	| claimOptions |
	claimOptions := RsStreamClaimOptions new.
	optionsBlock value: claimOptions.
	^ self xClaim: key group: group consumer: consumer minIdleTime: minIdleTime ids: ids options: claimOptions