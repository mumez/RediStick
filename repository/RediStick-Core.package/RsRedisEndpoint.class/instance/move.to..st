commands-generic
move: aKey to: zeroBasedDbIndex
	^ self
		unifiedCommand:
			{'MOVE'.
			aKey.
			zeroBasedDbIndex}