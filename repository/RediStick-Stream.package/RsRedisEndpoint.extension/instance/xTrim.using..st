*RediStick-Stream
xTrim: key using: optionsBlock
	| trimOptions |
	trimOptions := RsStreamTrimOptions new.
	optionsBlock value: trimOptions.
	^ self xTrim: key options: trimOptions