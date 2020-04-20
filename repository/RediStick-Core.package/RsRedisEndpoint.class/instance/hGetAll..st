commands-hashes
hGetAll: aKey
	^ Dictionary
		newFromPairs:
			(self
				unifiedCommand:
					{'HGETALL'.
					aKey})