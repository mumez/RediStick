commands-sets
sScanKey: aKey cursor: aCursor 
	^ self unifiedCommand: { 'SSCAN' . aKey . aCursor }