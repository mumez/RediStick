*RediStick-Stream
xInfoGroups: key
	| entries |
	entries := self unifiedCommand: { 'XINFO'. 'GROUPS'. key }.
	^ entries collect: [ :each | RsStreamGroupInfo fromOrderedCollection: each ]