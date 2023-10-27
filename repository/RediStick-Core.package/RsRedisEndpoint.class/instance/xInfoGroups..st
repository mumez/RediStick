commands-stream
xInfoGroups: key

	^ self unifiedCommand: { 'XINFO'. 'GROUPS'. key }