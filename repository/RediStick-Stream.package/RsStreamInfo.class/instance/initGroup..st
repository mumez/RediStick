initialization
initGroup: value
	| grps |
	grps := value isInteger
		        ifTrue: [ value ]
		        ifFalse: [
			        value collect: [ :each |
				        RsStreamConsumerInfo fromOrderedCollection: each ] ].
	^ self groups: grps