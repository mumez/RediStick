instance creation
named: aSymbol

	^ self channelsDict at: aSymbol asSymbol ifAbsentPut: [ 
		  | detected |
		  detected := self allSubclasses
			              detect: [ :each | each channelName = aSymbol ]
			              ifNone: [ ^ nil ].
		  detected new ]