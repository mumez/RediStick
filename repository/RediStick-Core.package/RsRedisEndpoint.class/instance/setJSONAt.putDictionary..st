commands-json
setJSONAt: objectKey putDictionary: aDictionary
	^ self
		unifiedCommand:
			{'JSON.SET'.
			objectKey.
			'.'.
			(NeoJSONWriter toString:  aDictionary)}