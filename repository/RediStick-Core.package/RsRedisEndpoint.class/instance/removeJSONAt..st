command-json
removeJSONAt: aString 
	^ self unifiedCommand: { 'JSON.DEL' . aString }