initialization
initGroups: value
	| grps |
	grps := value isInteger
		        ifTrue: [ value ]
		        ifFalse: [
			        value collect: [ :each |
				        RsStreamGroupInfo fromOrderedCollection: each ] ].
	^ self groups: grps