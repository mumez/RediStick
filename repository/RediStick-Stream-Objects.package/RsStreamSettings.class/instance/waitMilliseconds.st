accessing
waitMilliseconds
	^ self at: #waitMilliseconds ifAbsentPut: [1000]