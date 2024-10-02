instance creation
on: aRsStream from: fromId
	^ (self on: aRsStream)
		  initFromId: fromId;
		  yourself