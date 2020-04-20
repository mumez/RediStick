commands-generic
select: zeroBasedDbIndex
	^ self
		unifiedCommand:
			{'SELECT'.
			zeroBasedDbIndex}