commands-stream
xInfoCunsumes: key group: group

	^ self unifiedCommand: { 'XINFO'. 'CONSUMERS'. key. group }