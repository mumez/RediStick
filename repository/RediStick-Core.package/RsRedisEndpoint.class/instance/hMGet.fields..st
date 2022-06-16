commands-hashes
hMGet: aKey fields: fields 
	^ self unifiedCommand: {'HMGET'. aKey} , fields