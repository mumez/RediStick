*RediStick-Stream
xInfoConsumers: key group: group
	| entries |
	entries := self unifiedCommand: { 'XINFO'. 'CONSUMERS'. key. group }.
	entries ifNil: [ ^#() ].
	^ entries collect: [ :each | RsStreamConsumerInfo fromOrderedCollection: each ]