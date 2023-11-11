*RediStick-Stream
xInfoCunsumes: key group: group

	^ self unifiedCommand: { 'XINFO'. 'CONSUMERS'. key. group }