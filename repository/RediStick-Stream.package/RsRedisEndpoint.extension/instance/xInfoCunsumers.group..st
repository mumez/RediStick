*RediStick-Stream
xInfoCunsumers: key group: group
	| entries |
	entries := self unifiedCommand: { 'XINFO'. 'CONSUMERS'. key. group }.
	^ entries collect: [ :each | RsStreamConsumerInfo fromOrderedCollection: each ]