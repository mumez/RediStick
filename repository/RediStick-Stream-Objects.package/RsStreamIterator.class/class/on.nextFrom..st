instance creation
on: aRsStream nextFrom: fromId
	^ (self on: aRsStream)
		  initFromId: fromId;
		  initCurrentId: fromId;
		  yourself