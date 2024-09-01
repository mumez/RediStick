accessing
claimMinIdleMilliseconds
	^ self at: #claimMinIdleMilliseconds ifAbsentPut: [3600000]