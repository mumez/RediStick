*RediStick-Stream
xInfoGroups: key

	^ self unifiedCommand: { 'XINFO'. 'GROUPS'. key }